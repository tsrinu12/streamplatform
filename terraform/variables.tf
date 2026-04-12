# terraform/modules/cdn-edge-config/variables.tf

variable "project" {
  description = "Project name prefix"
  type        = string
  default     = "streamplatform"
}

variable "environment" {
  description = "Deployment environment: dev | stage | prod"
  type        = string
}

variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket storing HLS/DASH segments"
  type        = string
}

variable "s3_bucket_regional_domain" {
  description = "S3 bucket regional domain name (for CloudFront origin)"
  type        = string
}

variable "thumbs_bucket_regional_domain" {
  description = "S3 thumbnails bucket regional domain"
  type        = string
}

variable "streaming_gateway_alb_dns" {
  description = "ALB DNS name for the streaming-gateway service"
  type        = string
}

variable "cloudfront_public_key_pem" {
  description = "PEM-encoded RSA public key for CloudFront signed URL verification"
  type        = string
  sensitive   = true
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for CloudFront (must be in us-east-1)"
  type        = string
}

variable "waf_acl_arn" {
  description = "WAF Web ACL ARN to associate with CloudFront"
  type        = string
  default     = ""
}

variable "domain_aliases" {
  description = "Custom domain aliases for the CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "price_class" {
  description = "CloudFront price class: PriceClass_All | PriceClass_200 | PriceClass_100"
  type        = string
  default     = "PriceClass_All"
}

variable "geo_restriction_type" {
  description = "Geo restriction type: none | blacklist | whitelist"
  type        = string
  default     = "none"
}

variable "geo_restricted_countries" {
  description = "ISO 3166 country codes for geo restriction"
  type        = list(string)
  default     = []
}

variable "enable_access_logs" {
  description = "Enable CloudFront access logging to S3"
  type        = bool
  default     = true
}

variable "logs_bucket_domain" {
  description = "S3 bucket domain for CloudFront access logs"
  type        = string
  default     = ""
}

variable "jwt_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the JWT signing key"
  type        = string
}
