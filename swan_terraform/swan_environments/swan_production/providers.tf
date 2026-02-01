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
  region = var.swan_region
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = "swan_eks-infrastructure"
      Environment = "Production"
    }
  }
}

data "aws_eks_cluster" "swan_eks_cluster" {
  name = var.swan_eks_cluster_name
}

data "aws_eks_cluster_auth" "swan_eks_cluster_auth" {
  name = var.swan_eks_cluster_name
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.swan_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.swan_eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.swan_eks_cluster_auth.token
  }
}