resource "aws_s3_bucket" "stream_assets" {
  bucket = "streamplatform-assets-${var.environment}-${var.region}"
}

resource "aws_s3_bucket_public_access_block" "stream_assets" {
  bucket = aws_s3_bucket.stream_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "stream_assets" {
  bucket = aws_s3_bucket.stream_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "stream_assets" {
  bucket = aws_s3_bucket.stream_assets.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "bucket_id" {
  value = aws_s3_bucket.stream_assets.id
}

output "bucket_arn" {
  value = aws_s3_bucket.stream_assets.arn
}
