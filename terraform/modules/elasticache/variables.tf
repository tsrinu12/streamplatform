variable "replication_group_id" {
  description = "Replication group identifier"
  type        = string
}

variable "replication_group_description" {
  description = "Description of the replication group"
  type        = string
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "Instance class for cache nodes"
  type        = string
  default     = "cache.r6g.large"
}

variable "number_cache_clusters" {
  description = "Number of cache clusters in replication group"
  type        = number
  default     = 2
}

variable "port" {
  description = "Port number for Redis"
  type        = number
  default     = 6379
}

variable "parameter_group_family" {
  description = "Family for parameter group"
  type        = string
  default     = "redis7"
}

variable "parameters" {
  description = "List of parameter maps"
  type        = list(map(string))
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover"
  type        = bool
  default     = true
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = true
}

variable "at_rest_encryption_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Enable encryption in transit"
  type        = bool
  default     = true
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain snapshots"
  type        = number
  default     = 5
}

variable "snapshot_window" {
  description = "Daily time range for snapshots"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Weekly time range for maintenance"
  type        = string
  default     = "sun:05:00-sun:07:00"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
