terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.swan_aws_region
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = "swan_eks-infrastructure"
      Environment = "Production"
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.swan_eks.swan_eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.swan_eks.swan_eks_cluster_certificate_authority_data)
    token                  = module.swan_eks.swan_eks_cluster_auth_token
  }
}