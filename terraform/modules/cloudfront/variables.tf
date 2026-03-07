variable "environment" {
  description = "Environment name"
  type        = string
}

variable "s3_bucket_id" {
  description = "Origin S3 bucket ID"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "Origin S3 bucket domain name"
  type        = string
}

variable "cloudfront_oai_path" {
  description = "CloudFront Origin Access Identity path"
  type        = string
}
