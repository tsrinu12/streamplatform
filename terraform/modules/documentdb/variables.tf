variable "cluster_identifier" {
  description = "The cluster identifier for DocumentDB"
  type        = string
}

variable "master_username" {
  description = "Master username for DocumentDB"
  type        = string
  sensitive   = true
}

variable "master_password" {
  description = "Master password for DocumentDB"
  type        = string
  sensitive   = true
}

variable "instance_count" {
  description = "Number of instances in the cluster"
  type        = number
  default     = 2
}

variable "instance_class" {
  description = "Instance class for DocumentDB instances"
  type        = string
  default     = "db.r5.large"
}

variable "subnet_ids" {
  description = "List of subnet IDs for DocumentDB"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on cluster deletion"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
