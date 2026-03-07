# Variables for WAF Module

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "scope" {
  description = "WAF scope - REGIONAL for ALB or CLOUDFRONT for CloudFront"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "Scope must be either REGIONAL or CLOUDFRONT."
  }
}

# IP Allowlist Configuration
variable "enable_ip_allowlist" {
  description = "Enable IP allowlist rule"
  type        = bool
  default     = false
}

variable "allowed_ip_list" {
  description = "List of IP addresses to allow (CIDR notation)"
  type        = list(string)
  default     = []
}

# IP Blocklist Configuration
variable "enable_ip_blocklist" {
  description = "Enable IP blocklist rule"
  type        = bool
  default     = false
}

variable "blocked_ip_list" {
  description = "List of IP addresses to block (CIDR notation)"
  type        = list(string)
  default     = []
}

# Rate Limiting Configuration
variable "enable_rate_limiting" {
  description = "Enable rate limiting rule"
  type        = bool
  default     = true
}

variable "rate_limit_threshold" {
  description = "Rate limit threshold (requests per 5 minutes)"
  type        = number
  default     = 2000
}

# Resource Association
variable "associate_with_cloudfront" {
  description = "Associate WAF with CloudFront distribution"
  type        = bool
  default     = false
}

variable "cloudfront_arn" {
  description = "ARN of the CloudFront distribution to associate with WAF"
  type        = string
  default     = ""
}

variable "associate_with_alb" {
  description = "Associate WAF with Application Load Balancer"
  type        = bool
  default     = false
}

variable "alb_arn" {
  description = "ARN of the ALB to associate with WAF"
  type        = string
  default     = ""
}

# Logging Configuration
variable "enable_logging" {
  description = "Enable WAF logging to CloudWatch"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
}
