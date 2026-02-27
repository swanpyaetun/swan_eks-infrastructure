module "swan_ecr" {
  source                            = "../../swan_modules/swan_ecr"
  swan_private_ecr_namespace        = var.swan_private_ecr_namespace
  swan_private_ecr_repository_names = var.swan_private_ecr_repository_names
}

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
  source                                           = "../../swan_modules/swan_eks"
  swan_eks_cluster_name                            = var.swan_eks_cluster_name
  swan_eks_cluster_version                         = var.swan_eks_cluster_version
  swan_private_subnet_ids                          = module.swan_vpc.swan_private_subnet_ids
  swan_system_eks_node_group_instance_types        = var.swan_system_eks_node_group_instance_types
  swan_system_eks_node_group_desired_size          = var.swan_system_eks_node_group_desired_size
  swan_system_eks_node_group_min_size              = var.swan_system_eks_node_group_min_size
  swan_system_eks_node_group_max_size              = var.swan_system_eks_node_group_max_size
  swan_vpc_cni_eks_addon_version                   = var.swan_vpc_cni_eks_addon_version
  swan_coredns_eks_addon_version                   = var.swan_coredns_eks_addon_version
  swan_kube_proxy_eks_addon_version                = var.swan_kube_proxy_eks_addon_version
  swan_eks_pod_identity_agent_eks_addon_version    = var.swan_eks_pod_identity_agent_eks_addon_version
  swan_eks_node_monitoring_agent_eks_addon_version = var.swan_eks_node_monitoring_agent_eks_addon_version
  swan_ci_iam_role_arn                             = var.swan_ci_iam_role_arn
}

module "swan_helm" {
  source                                     = "../../swan_modules/swan_helm"
  swan_vpc_id                                = module.swan_vpc.swan_vpc_id
  swan_eks_cluster_name                      = var.swan_eks_cluster_name
  swan_eks_cluster_endpoint                  = module.swan_eks.swan_eks_cluster_endpoint
  swan_karpenter_interruption_sqs_queue_name = module.swan_eks.swan_karpenter_interruption_sqs_queue_name
  swan_domain                                = var.swan_domain
  depends_on                                 = [module.swan_eks]
}