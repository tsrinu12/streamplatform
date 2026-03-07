providers.tf  terraform {
  required_version = \">= 1.0.0\"

  required_providers {
    aws = {
      source  = \"hashicorp/aws\"
      version = \"~> 5.0\"
    }
    kubernetes = {
      source  = \"hashicorp/kubernetes\"
      version = \"~> 2.0\"
    }
    helm = {
      source  = \"hashicorp/helm\"
      version = \"~> 2.0\"
    }
  }

  backend \"s3\" {
    bucket         = \"streamplatform-terraform-state-prod\"
    key            = \"terraform.tfstate\"
    region         = \"us-east-1\"
    dynamodb_table = \"terraform-lock-prod\"
    encrypt        = true
  }
}

provider \"aws\" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

provider \"kubernetes\" {
  host                   = module.main.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.main.eks_cluster_certificate_authority_data)
  exec {
    api_version = \"client.authentication.k8s.io/v1beta1\"
    args        = [\"eks\", \"get-token\", \"--cluster-name\", module.main.eks_cluster_name]
    command     = \"aws\"
  }
}

provider \"helm\" {
  kubernetes {
    host                   = module.main.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.main.eks_cluster_certificate_authority_data)
    exec {
      api_version = \"client.authentication.k8s.io/v1beta1\"
      args        = [\"eks\", \"get-token\", \"--cluster-name\", module.main.eks_cluster_name]
      command     = \"aws\"
    }
  }
}
