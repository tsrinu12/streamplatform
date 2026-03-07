# Terraform AWS WAF Module
# AWS WAF with managed and custom rules for CloudFront and ALB protection

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
  }
}

locals {
  name_prefix = "${var.environment}-sp"
}

# IP Set for allowed IPs
resource "aws_wafv2_ip_set" "allowed_ips" {
  count              = var.enable_ip_allowlist ? 1 : 0
  name               = "${local.name_prefix}-allowed-ips"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.allowed_ip_list
  tags = {
    Name = "${local.name_prefix}-allowed-ips"
  }
}

# IP Set for blocked IPs
resource "aws_wafv2_ip_set" "blocked_ips" {
  count              = var.enable_ip_blocklist ? 1 : 0
  name               = "${local.name_prefix}-blocked-ips"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.blocked_ip_list
  tags = {
    Name = "${local.name_prefix}-blocked-ips"
  }
}

# WAF Web ACL
resource "aws_wafv2_web_acl" "main" {
  name  = "${local.name_prefix}-web-acl"
  scope = var.scope

  default_action {
    allow {}
  }

  # AWS Managed Rules - Core Rule Set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0

    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"

        excluded_rule {
          name = "SizeRestrictions_BODY"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-core-rule-set"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Known Bad Inputs
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 1

    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - SQL Injection Protection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 2

    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-sqli-protection"
      sampled_requests_enabled   = true
    }
  }

  # IP Allowlist Rule
  dynamic "rule" {
    for_each = var.enable_ip_allowlist ? [1] : []

    content {
      name     = "AllowlistIPRule"
      priority = 3

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.allowed_ips[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name_prefix}-allowlist-ips"
        sampled_requests_enabled   = true
      }
    }
  }

  # IP Blocklist Rule
  dynamic "rule" {
    for_each = var.enable_ip_blocklist ? [1] : []

    content {
      name     = "BlocklistIPRule"
      priority = 4

      action {
        block {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.blocked_ips[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name_prefix}-blocklist-ips"
        sampled_requests_enabled   = true
      }
    }
  }

  # Rate Limiting Rule
  dynamic "rule" {
    for_each = var.enable_rate_limiting ? [1] : []

    content {
      name     = "RateLimitingRule"
      priority = 5

      action {
        block {}
      }

      statement {
        rate_based_statement {
          limit              = var.rate_limit_threshold
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name_prefix}-rate-limiting"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-web-acl"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "${local.name_prefix}-web-acl"
    Environment = var.environment
  }
}

# CloudFront Distribution Association
resource "aws_wafv2_web_acl_association" "cloudfront" {
  count        = var.associate_with_cloudfront ? 1 : 0
  resource_arn = var.cloudfront_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# ALB Association
resource "aws_wafv2_web_acl_association" "alb" {
  count        = var.associate_with_alb ? 1 : 0
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# CloudWatch Log Group for WAF Logs
resource "aws_cloudwatch_log_group" "waf_log_group" {
  count             = var.enable_logging ? 1 : 0
  name              = "/aws/waf/${local.name_prefix}"
  retention_in_days = var.log_retention_days
  tags = {
    Name = "${local.name_prefix}-waf-logs"
  }
}

# WAF Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count                   = var.enable_logging ? 1 : 0
  resource_arn            = aws_wafv2_web_acl.main.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group[0].arn]

  logging_filter {
    default_behavior = "KEEP"

    filter {
      behavior = "KEEP"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }

      requirement = "MEETS_ANY"
    }
  }
}

# Output the Web ACL ARN
output "web_acl_arn" {
  value       = aws_wafv2_web_acl.main.arn
  description = "ARN of the WAF Web ACL"
}

output "web_acl_id" {
  value       = aws_wafv2_web_acl.main.id
  description = "ID of the WAF Web ACL"
}

output "web_acl_capacity" {
  value       = aws_wafv2_web_acl.main.capacity
  description = "WAF Web ACL capacity"
}
