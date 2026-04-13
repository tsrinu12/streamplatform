# terraform/modules/cdn-edge-config/main.tf
# CloudFront streaming distribution with:
#   - Signed URL auth for HLS/DASH segments
#   - Geo-restriction / geo-blocking
#   - Lambda@Edge for token validation and geo-routing
#   - Separate origins: S3 (segments), streaming-gateway (playlists), thumbs (thumbnails)
#   - Custom cache policies per content type
#   - WAF integration
#   - Real-time logging to Kinesis

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.40"
    }
  }
}

# ─── S3 Origin Access Control ──────────────────────────────────────────────

resource "aws_cloudfront_origin_access_control" "segments" {
  name                              = "${var.project}-${var.environment}-segments-oac"
  description                       = "OAC for HLS/DASH segment bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ─── Cache Policies ────────────────────────────────────────────────────────

resource "aws_cloudfront_cache_policy" "segments" {
  name        = "${var.project}-${var.environment}-segments-cache"
  comment     = "Cache policy for HLS/DASH segments — long TTL, immutable"
  default_ttl = 86400     # 24h
  max_ttl     = 604800    # 7d
  min_ttl     = 3600      # 1h

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config { cookie_behavior = "none" }
    headers_config  { header_behavior = "none" }
    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings { items = ["version"] }
    }
  }
}

resource "aws_cloudfront_cache_policy" "playlists" {
  name        = "${var.project}-${var.environment}-playlists-cache"
  comment     = "Cache policy for m3u8 playlists — short TTL, no-cache"
  default_ttl = 0
  max_ttl     = 10
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = false
    enable_accept_encoding_gzip   = true

    cookies_config { cookie_behavior = "none" }
    headers_config {
      header_behavior = "whitelist"
      headers { items = ["Authorization", "Range"] }
    }
    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings { items = ["token", "v"] }
    }
  }
}

resource "aws_cloudfront_cache_policy" "thumbnails" {
  name        = "${var.project}-${var.environment}-thumbs-cache"
  comment     = "Cache policy for thumbnails — 1h TTL"
  default_ttl = 3600
  max_ttl     = 86400
  min_ttl     = 60

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config { cookie_behavior = "none" }
    headers_config  { header_behavior = "none" }
    query_strings_config { query_string_behavior = "none" }
  }
}

# ─── Origin Request Policy ─────────────────────────────────────────────────

resource "aws_cloudfront_origin_request_policy" "streaming" {
  name    = "${var.project}-${var.environment}-streaming-origin-policy"
  comment = "Forward auth and range headers to streaming-gateway"

  cookies_config    { cookie_behavior = "none" }
  query_strings_config { query_string_behavior = "all" }
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = [
        "Authorization",
        "Range",
        "Origin",
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
        "CloudFront-Viewer-Country",
        "CloudFront-Viewer-Country-Region",
      ]
    }
  }
}

# ─── Lambda@Edge for Token Auth ───────────────────────────────────────────

resource "aws_iam_role" "lambda_edge" {
  name = "${var.project}-${var.environment}-lambda-edge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_edge_basic" {
  role       = aws_iam_role.lambda_edge.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_edge_secrets" {
  name = "${var.project}-${var.environment}-lambda-edge-secrets"
  role = aws_iam_role.lambda_edge.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.project}/${var.environment}/streaming/*"
      }
    ]
  })
}

data "archive_file" "token_validator" {
  type        = "zip"
  output_path = "${path.module}/lambda/token_validator.zip"
  source {
    content  = file("${path.module}/lambda/token_validator.js")
    filename = "index.js"
  }
}

resource "aws_lambda_function" "token_validator" {
  # Lambda@Edge MUST be deployed to us-east-1
  provider         = aws.us_east_1
  function_name    = "${var.project}-${var.environment}-stream-token-validator"
  role             = aws_iam_role.lambda_edge.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.token_validator.output_path
  source_code_hash = data.archive_file.token_validator.output_base64sha256
  publish          = true   # Lambda@Edge requires a published version

  memory_size = 128
  timeout     = 5

  environment {
    variables = {
      JWT_SECRET_ARN = var.jwt_secret_arn
      ENVIRONMENT    = var.environment
    }
  }
}

# ─── CloudFront Key Group (for signed URLs) ────────────────────────────────

resource "aws_cloudfront_public_key" "signing" {
  comment     = "${var.project} ${var.environment} CloudFront signing key"
  encoded_key = var.cloudfront_public_key_pem
  name        = "${var.project}-${var.environment}-signing-key"
}

resource "aws_cloudfront_key_group" "streaming" {
  comment = "Key group for signed HLS/DASH segment URLs"
  items   = [aws_cloudfront_public_key.signing.id]
  name    = "${var.project}-${var.environment}-key-group"
}

# ─── CloudFront Distribution ───────────────────────────────────────────────

resource "aws_cloudfront_distribution" "streaming" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project} ${var.environment} streaming CDN"
  default_root_object = ""
  price_class         = var.price_class    # PriceClass_All for global, PriceClass_100 for US/EU
  aliases             = var.domain_aliases  # e.g. ["cdn.streamplatform.io"]
  web_acl_id          = var.waf_acl_arn

  # ── Origin 1: S3 for raw HLS/DASH segments ──────────────────────────────
  origin {
    domain_name              = var.s3_bucket_regional_domain
    origin_id                = "s3-segments"
    origin_access_control_id = aws_cloudfront_origin_access_control.segments.id

    origin_shield {
      enabled              = true
      origin_shield_region = var.aws_region
    }
  }

  # ── Origin 2: Streaming Gateway ALB (for playlists & session APIs) ──────
  origin {
    domain_name = var.streaming_gateway_alb_dns
    origin_id   = "streaming-gateway"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      origin_read_timeout    = 60
      origin_keepalive_timeout = 60
    }
  }

  # ── Origin 3: S3 for thumbnails ──────────────────────────────────────────
  origin {
    domain_name              = var.thumbs_bucket_regional_domain
    origin_id                = "s3-thumbs"
    origin_access_control_id = aws_cloudfront_origin_access_control.segments.id
  }

  # ── Behaviour 1: HLS master + quality playlists (.m3u8) via gateway ──────
  ordered_cache_behavior {
    path_pattern             = "/stream/*/master.m3u8"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "streaming-gateway"
    cache_policy_id          = aws_cloudfront_cache_policy.playlists.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.streaming.id
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.token_validator.qualified_arn
      include_body = false
    }
  }

  ordered_cache_behavior {
    path_pattern             = "/stream/*/*.m3u8"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "streaming-gateway"
    cache_policy_id          = aws_cloudfront_cache_policy.playlists.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.streaming.id
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
  }

  # ── Behaviour 2: HLS segments (.ts) directly from S3 with signed URLs ────
  ordered_cache_behavior {
    path_pattern           = "/stream/*/*.ts"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-segments"
    cache_policy_id        = aws_cloudfront_cache_policy.segments.id
    viewer_protocol_policy = "redirect-to-https"
    compress               = false    # TS segments are already compressed

    trusted_key_groups = [aws_cloudfront_key_group.streaming.id]
  }

  # ── Behaviour 3: DASH manifests and segments ──────────────────────────────
  ordered_cache_behavior {
    path_pattern             = "/stream/*/manifest.mpd"
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "streaming-gateway"
    cache_policy_id          = aws_cloudfront_cache_policy.playlists.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.streaming.id
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
  }

  ordered_cache_behavior {
    path_pattern           = "/stream/*/dash/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-segments"
    cache_policy_id        = aws_cloudfront_cache_policy.segments.id
    viewer_protocol_policy = "redirect-to-https"
    compress               = false

    trusted_key_groups = [aws_cloudfront_key_group.streaming.id]
  }

  # ── Behaviour 4: Thumbnails from S3 ──────────────────────────────────────
  ordered_cache_behavior {
    path_pattern           = "/thumb/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-thumbs"
    cache_policy_id        = aws_cloudfront_cache_policy.thumbnails.id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  # ── Default behaviour: streaming-gateway for session/API calls ────────────
  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "streaming-gateway"
    cache_policy_id          = aws_cloudfront_cache_policy.playlists.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.streaming.id
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
  }

  # ── Geo restriction ───────────────────────────────────────────────────────
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type   # "blacklist" | "whitelist" | "none"
      locations        = var.geo_restricted_countries
    }
  }

  # ── TLS ───────────────────────────────────────────────────────────────────
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # ── Real-time logging ─────────────────────────────────────────────────────
  dynamic "logging_config" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      include_cookies = false
      bucket          = var.logs_bucket_domain
      prefix          = "cloudfront/${var.environment}/"
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "cdn-edge-config"
  }
}

# ─── S3 Bucket Policy — allow CloudFront OAC ──────────────────────────────

data "aws_iam_policy_document" "s3_cloudfront" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.streaming.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "segments" {
  bucket = var.s3_bucket_name
  policy = data.aws_iam_policy_document.s3_cloudfront.json
}
