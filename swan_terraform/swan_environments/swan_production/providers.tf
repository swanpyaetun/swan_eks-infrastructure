provider "aws" {
  region = "ap-southeast-1"
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