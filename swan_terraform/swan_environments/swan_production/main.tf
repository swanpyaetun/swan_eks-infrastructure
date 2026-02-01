module "swan_vpc" {
  source                          = "../../swan_modules/swan_vpc"
  swan_vpc_cidr_block             = var.swan_vpc_cidr_block
  swan_private_subnet_cidr_blocks = var.swan_private_subnet_cidr_blocks
  swan_availability_zones         = var.swan_availability_zones
  swan_private_subnet_tags        = var.swan_private_subnet_tags
  swan_name_prefix                = var.swan_eks_cluster_name
}

module "swan_eks" {
  source                   = "../../swan_modules/swan_eks"
  swan_eks_cluster_name    = var.swan_eks_cluster_name
  swan_eks_cluster_version = var.swan_eks_cluster_version
  swan_private_subnet_ids  = module.swan_vpc.swan_private_subnet_ids
  swan_eks_addons          = var.swan_eks_addons
  swan_eks_node_groups     = var.swan_eks_node_groups
  swan_aws_account_id      = var.swan_aws_account_id
}

module "swan_aws_load_balancer_controller" {
  source                = "../../swan_modules/swan_aws_load_balancer_controller"
  swan_eks_cluster_name = var.swan_eks_cluster_name
  swan_vpc_id           = module.swan_vpc.swan_vpc_id
  depends_on            = [module.swan_eks]
}