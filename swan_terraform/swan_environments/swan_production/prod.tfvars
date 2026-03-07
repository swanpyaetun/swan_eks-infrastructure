# swan_vpc
swan_vpc_cidr_block            = "10.0.0.0/16"
swan_availability_zones        = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
swan_public_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
swan_public_subnet_tags = {
  "kubernetes.io/role/elb" = "1"
}
swan_private_subnet_cidr_blocks = ["10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]
swan_private_subnet_tags = {
  "kubernetes.io/role/internal-elb" = "1"
  # for Karpenter auto-discovery
  "karpenter.sh/discovery" = "swan_production_eks_cluster"
}

# swan_eks
swan_eks_cluster_name                            = "swan_production_eks_cluster"
swan_eks_cluster_version                         = "1.35"
swan_system_eks_node_group_instance_types        = ["t3.medium"]
swan_system_eks_node_group_desired_size          = 2
swan_system_eks_node_group_min_size              = 2
swan_system_eks_node_group_max_size              = 2
swan_vpc_cni_eks_addon_version                   = "v1.21.1-eksbuild.3"
swan_coredns_eks_addon_version                   = "v1.13.2-eksbuild.1"
swan_kube_proxy_eks_addon_version                = "v1.35.0-eksbuild.2"
swan_eks_pod_identity_agent_eks_addon_version    = "v1.3.10-eksbuild.2"
swan_eks_node_monitoring_agent_eks_addon_version = "v1.5.2-eksbuild.1"
swan_domain_name                                 = "swanpyaetun.com"