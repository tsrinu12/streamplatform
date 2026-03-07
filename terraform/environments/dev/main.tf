# Dev Environment Configuration
# Multi-environment microservices platform

terraform {
  required_version = ">= 1.6.0"
  backend "s3" {
    bucket         = "sp-terraform-state-dev"
    key            = "environments/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "sp-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-south-1"
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "StreamPlatform"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  environment         = "dev"
  vpc_cidr            = "10.10.0.0/16"
  enable_nat_gateway  = true
  single_nat_gateway  = true
  enable_flow_logs    = true
  flow_log_retention  = 14
}

module "eks" {
  source = "../../modules/eks"

  environment          = "dev"
  cluster_name         = "sp-dev-cluster"
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  public_subnet_ids    = module.vpc.public_subnet_ids
  enable_public_access = true

  general_node_config = {
    instance_types = ["t3.large"]
    capacity_type  = "SPOT"
    min_size       = 2
    max_size       = 5
    desired_size   = 2
    disk_size      = 50
  }
}
