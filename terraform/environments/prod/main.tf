terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket         = "streamplatform-terraform-state-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "streamplatform-terraform-lock-prod"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "production"
      Project     = "StreamPlatform"
      ManagedBy   = "Terraform"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"
  
  environment = "prod"
  vpc_cidr    = var.vpc_cidr
  azs         = var.availability_zones
}

module "eks" {
  source = "../../modules/eks"
  
  cluster_name    = "${var.project_name}-prod"
  cluster_version = var.eks_cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
}

module "rds" {
  source = "../../modules/rds"
  
  identifier          = "${var.project_name}-prod"
  instance_class      = var.rds_instance_class
  allocated_storage   = var.rds_allocated_storage
  engine_version      = var.rds_engine_version
  multi_az            = true
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.database_subnet_ids
}

module "elasticache" {
  source = "../../modules/elasticache"
  
  replication_group_id          = "${var.project_name}-prod-redis"
  replication_group_description = "Production Redis cluster"
  node_type                     = var.elasticache_node_type
  number_cache_clusters         = var.elasticache_num_nodes
  subnet_ids                    = module.vpc.private_subnet_ids
  security_group_ids            = [module.vpc.default_security_group_id]
  
  tags = {
    Environment = "production"
  }
}

module "documentdb" {
  source = "../../modules/documentdb"
  
  cluster_identifier = "${var.project_name}-prod"
  master_username    = var.documentdb_master_username
  master_password    = var.documentdb_master_password
  instance_count     = var.documentdb_instance_count
  instance_class     = var.documentdb_instance_class
  subnet_ids         = module.vpc.database_subnet_ids
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  
  backup_retention_period = 30
  preferred_backup_window = "03:00-04:00"
  skip_final_snapshot     = false
  
  tags = {
    Environment = "production"
  }
}
