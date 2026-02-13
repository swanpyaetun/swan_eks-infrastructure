module "swan_vpc" {
  source                          = "../../swan_modules/swan_vpc"
  swan_vpc_cidr_block             = var.swan_vpc_cidr_block
  swan_availability_zones         = var.swan_availability_zones
  swan_public_subnet_cidr_blocks  = var.swan_public_subnet_cidr_blocks
  swan_public_subnet_tags         = var.swan_public_subnet_tags
  swan_private_subnet_cidr_blocks = var.swan_private_subnet_cidr_blocks
  swan_private_subnet_tags        = var.swan_private_subnet_tags
  swan_name_prefix                = var.swan_eks_cluster_name
}

module "swan_eks" {
  source                                        = "../../swan_modules/swan_eks"
  swan_eks_cluster_name                         = var.swan_eks_cluster_name
  swan_eks_cluster_version                      = var.swan_eks_cluster_version
  swan_private_subnet_ids                       = module.swan_vpc.swan_private_subnet_ids
  swan_eks_node_groups                          = var.swan_eks_node_groups
  swan_vpc_cni_eks_addon_version                = var.swan_vpc_cni_eks_addon_version
  swan_coredns_eks_addon_version                = var.swan_coredns_eks_addon_version
  swan_kube_proxy_eks_addon_version             = var.swan_kube_proxy_eks_addon_version
  swan_eks_pod_identity_agent_eks_addon_version = var.swan_eks_pod_identity_agent_eks_addon_version
  swan_ci_role_arn                              = var.swan_ci_role_arn
}

module "swan_aws_load_balancer_controller" {
  source                = "../../swan_modules/swan_aws_load_balancer_controller"
  swan_eks_cluster_name = var.swan_eks_cluster_name
  swan_vpc_id           = module.swan_vpc.swan_vpc_id
  depends_on            = [module.swan_eks]
}

module "swan_argocd" {
  source                = "../../swan_modules/swan_argocd"
  swan_aws_region       = var.swan_aws_region
  swan_ecr_registry     = var.swan_ecr_registry
  swan_eks_cluster_name = var.swan_eks_cluster_name
  depends_on            = [module.swan_eks]
}

module "swan_sealed_secrets" {
  source     = "../../swan_modules/swan_sealed_secrets"
  depends_on = [module.swan_eks]
}

module "swan_metrics_server" {
  source     = "../../swan_modules/swan_metrics_server"
  depends_on = [module.swan_eks]
}

module "swan_ecr" {
  source                    = "../../swan_modules/swan_ecr"
  swan_ecr_namespace        = var.swan_ecr_namespace
  swan_ecr_repository_names = var.swan_ecr_repository_names
}