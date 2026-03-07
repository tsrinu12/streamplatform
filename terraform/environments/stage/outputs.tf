outputs.tf  output \"vpc_id\" {
  description = \"The ID of the VPC\"
  value       = module.main.vpc_id
}

output \"eks_cluster_endpoint\" {
  description = \"Endpoint for EKS control plane\"
  value       = module.main.eks_cluster_endpoint
}

output \"eks_cluster_name\" {
  description = \"Kubernetes Cluster Name\"
  value       = module.main.eks_cluster_name
}

output \"rds_endpoint\" {
  description = \"The connection endpoint for the RDS instance\"
  value       = module.main.rds_endpoint
}

output \"redis_endpoint\" {
  description = \"The endpoint of the ElastiCache cluster\"
  value       = module.main.redis_endpoint
}

output \"docdb_endpoint\" {
  description = \"The endpoint of the DocumentDB cluster\"
  value       = module.main.docdb_endpoint
}

output \"msk_bootstrap_brokers\" {
  description = \"MSK bootstrap brokers\"
  value       = module.main.msk_bootstrap_brokers
}

output \"opensearch_endpoint\" {
  description = \"Domain-specific endpoint used to submit index, search, and data upload requests\"
  value       = module.main.opensearch_endpoint
}

output \"ecr_repository_urls\" {
  description = \"URLs of the created ECR repositories\"
  value       = module.main.ecr_repository_urls
}

output \"cloudfront_domain_name\" {
  description = \"The domain name of the CloudFront distribution\"
  value       = module.main.cloudfront_domain_name
}

output \"s3_bucket_names\" {
  description = \"Names of the created S3 buckets\"
  value       = module.main.s3_bucket_names
}
