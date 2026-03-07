# Production Environment Configuration

aws_region = "us-east-1"
project_name = "streamplatform"

availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_cidr = "10.0.0.0/16"

# EKS Configuration
eks_cluster_version = "1.28"
eks_node_instance_types = ["m5.xlarge", "m5.2xlarge"]
eks_desired_capacity = 6
eks_min_capacity = 3
eks_max_capacity = 20

# RDS Configuration
rds_instance_class = "db.r6g.xlarge"
rds_allocated_storage = 500
rds_engine_version = "15.4"
rds_multi_az = true
rds_backup_retention_period = 30

# ElastiCache Configuration
elasticache_node_type = "cache.r6g.xlarge"
elasticache_num_nodes = 3

# DocumentDB Configuration
documentdb_instance_class = "db.r6g.xlarge"
documentdb_instance_count = 3

# MSK Configuration  
msk_instance_type = "kafka.m5.2xlarge"
msk_number_of_broker_nodes = 3
msk_ebs_volume_size = 2000

# S3 Configuration
enable_versioning = true
enable_encryption = true

# CloudFront Configuration
price_class = "PriceClass_All"

# Tags
tags = {
  Environment = "production"
  Project     = "StreamPlatform"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
}
