# terraform/modules/cdn-edge-config/outputs.tf

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.streaming.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain (e.g. d1abc.cloudfront.net)"
  value       = aws_cloudfront_distribution.streaming.domain_name
}

output "cloudfront_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.streaming.arn
}

output "cloudfront_key_id" {
  description = "CloudFront public key ID (used for signed URL generation)"
  value       = aws_cloudfront_public_key.signing.id
}

output "cloudfront_key_group_id" {
  description = "CloudFront key group ID"
  value       = aws_cloudfront_key_group.streaming.id
}

output "lambda_edge_arn" {
  description = "Lambda@Edge token validator qualified ARN"
  value       = aws_lambda_function.token_validator.qualified_arn
}

output "segments_cache_policy_id" {
  description = "Cache policy ID for HLS/DASH segments"
  value       = aws_cloudfront_cache_policy.segments.id
}
