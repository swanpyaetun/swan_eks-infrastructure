swan_region                    = "ap-southeast-1"
swan_vpc_cidr_block            = "10.0.0.0/16"
swan_availability_zones        = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
swan_public_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
swan_public_subnet_tags = {
  "kubernetes.io/role/elb" = "1"
}
swan_private_subnet_cidr_blocks = ["10.0.64.0/18", "10.0.128.0/18", "10.0.192.0/18"]
swan_private_subnet_tags = {
  "kubernetes.io/role/internal-elb" = "1"
}
swan_eks_cluster_name    = "swan_production_eks_cluster"
swan_eks_cluster_version = "1.35"
swan_eks_addons = {
  eks-pod-identity-agent = {
    addon_version = "v1.3.10-eksbuild.2"
  }
}
swan_eks_node_groups = {
  swan_ondemand_nodegroup = {
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 0
      min_size     = 0
      max_size     = 1
    }
  }
  swan_spot_nodegroup = {
    instance_types = ["t3.medium"]
    capacity_type  = "SPOT"
    scaling_config = {
      desired_size = 2
      min_size     = 0
      max_size     = 2
    }
  }
}