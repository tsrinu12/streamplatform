variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "eks_instance_types" {
  description = "EKS Instance types"
  type        = list(string)
}

variable "eks_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "eks_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "eks_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_name" {
  description = "RDS database name"
  type        = string
}

variable "redis_node_type" {
  description = "ElastiCache node type"
  type        = string
}

variable "docdb_instance_class" {
  description = "DocumentDB instance class"
  type        = string
}

variable "msk_instance_type" {
  description = "MSK instance type"
  type        = string
}

variable "opensearch_instance_type" {
  description = "OpenSearch instance type"
  type        = string
}

variable "repositories" {
  description = "List of ECR repositories"
  type        = list(string)
}

variable "app_secrets" {
  description = "Map of secrets for the application"
  type        = map(string)
  sensitive   = true
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for monitoring alerts"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
