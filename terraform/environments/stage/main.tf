module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  common_tags = var.common_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  instance_types  = var.eks_instance_types
  desired_size    = var.eks_desired_size
  max_size        = var.eks_max_size
  min_size        = var.eks_min_size
  common_tags     = var.common_tags
}

module "rds" {
  source = "../../modules/rds"

  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  instance_class  = var.rds_instance_class
  db_name         = var.db_name
  common_tags     = var.common_tags
}

module "elasticache" {
  source = "../../modules/elasticache"

  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  node_type       = var.redis_node_type
  common_tags     = var.common_tags
}

module "documentdb" {
  source = "../../modules/documentdb"

  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  instance_class  = var.docdb_instance_class
  common_tags     = var.common_tags
}

module "msk" {
  source = "../../modules/msk"

  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  instance_type   = var.msk_instance_type
  common_tags     = var.common_tags
}

module "opensearch" {
  source = "../../modules/opensearch"

  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  instance_type   = var.opensearch_instance_type
  common_tags     = var.common_tags
}

module "s3" {
  source = "../../modules/s3"

  bucket_name = "${var.environment}-streamplatform-assets"
  common_tags = var.common_tags
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  environment     = var.environment
  s3_bucket_id    = module.s3.bucket_id
  s3_bucket_arn   = module.s3.bucket_arn
  common_tags     = var.common_tags
}

module "waf" {
  source = "../../modules/waf"

  environment     = var.environment
  common_tags     = var.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  repositories = var.repositories
  common_tags  = var.common_tags
}

module "iam" {
  source = "../../modules/iam"

  cluster_name = var.cluster_name
  common_tags  = var.common_tags
}

module "secrets" {
  source = "../../modules/secrets-manager"

  environment   = var.environment
  secret_name   = "app-secrets"
  secret_values = var.app_secrets
  common_tags   = var.common_tags
}

module "monitoring" {
  source = "../../modules/cloudwatch"

  environment       = var.environment
  cluster_name      = var.cluster_name
  db_instance_id    = module.rds.db_instance_id
  sns_topic_arn     = var.sns_topic_arn
  common_tags       = var.common_tags
  aws_region        = var.aws_region
}
