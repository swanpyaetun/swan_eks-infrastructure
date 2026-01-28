module "swan_vpc" {
  source                          = "../../swan_modules/swan_vpc"
  swan_vpc_cidr_block             = var.swan_vpc_cidr_block
  swan_private_subnet_cidr_blocks = var.swan_private_subnet_cidr_blocks
  swan_eks_cluster_name           = var.swan_eks_cluster_name
}

module "swan_eks" {
  source                   = "../../swan_modules/swan_eks"
  swan_eks_cluster_name    = var.swan_eks_cluster_name
  swan_eks_cluster_version = var.swan_eks_cluster_version
  swan_private_subnet_ids  = module.swan_vpc.swan_private_subnet_ids
  swan_eks_node_groups     = var.swan_eks_node_groups
  swan_aws_account_id      = var.swan_aws_account_id
}