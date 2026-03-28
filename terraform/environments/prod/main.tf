provider "aws" {
  region = var.region
}

# Production VPC with public and private subnets
module "vpc" {
  source = "../../modules/vpc"

  name = "streamplatform-prod-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Environment = "production"
    Project     = "StreamPlatform"
  }
}

# Production EKS Cluster with GPU support
module "eks" {
  source = "../../modules/eks"

  cluster_name    = "streamplatform-prod-cluster"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = {
    # General purpose microservices
    general = {
      min_size     = 3
      max_size     = 10
      desired_size = 3
      instance_types = ["m5.large"]
    }

    # GPU-optimized for V-JEPA and AI inference
    ai_inference = {
      min_size     = 2
      max_size     = 5
      desired_size = 2
      instance_types = ["g4dn.xlarge"]
      labels = {
        workload = "ai-inference"
      }
      taints = [
        {
          key    = "nvidia.com/gpu"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  # Security best practices: Enable private access and disable public access
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  # KMS encryption for secrets
  create_kms_key = true
  cluster_encryption_config = {
    resources = ["secrets"]
  }

  tags = {
    Environment = "production"
  }
}

# Production Managed Streaming for Kafka (MSK)
module "msk" {
  source = "../../modules/msk"

  cluster_name           = "streamplatform-prod-msk"
  kafka_version          = "3.6.0"
  number_of_broker_nodes = 3
  instance_type          = "kafka.m5.large"
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnets

  encryption_info = {
    encryption_at_rest_kms_key_arn = module.eks.kms_key_arn
    encryption_in_transit = {
      client_broker = "TLS"
      in_cluster    = true
    }
  }
}

# AWS WAF for public-facing web-app
module "waf" {
  source = "../../modules/waf"

  name = "streamplatform-prod-waf"
  scope = "CLOUDFRONT"
}
