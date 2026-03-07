variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "general_node_config" {
  type = object({
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
  })
}

variable "enable_gpu_nodes" {
  type    = bool
  default = false
}

variable "gpu_node_config" {
  type = object({
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
  })
  default = null
}

variable "enable_public_access" {
  type    = bool
  default = true
}

variable "enable_private_access" {
  type    = bool
  default = true
}
