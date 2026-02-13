variable "swan_eks_cluster_name" {
  type = string
}

variable "swan_eks_cluster_version" {
  type = string
}

variable "swan_private_subnet_ids" {
  type = list(string)
}

variable "swan_eks_node_groups" {
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_size = number
      min_size     = number
      max_size     = number
    })
  }))
}

variable "swan_vpc_cni_eks_addon_version" {
  type = string
}

variable "swan_coredns_eks_addon_version" {
  type = string
}

variable "swan_kube_proxy_eks_addon_version" {
  type = string
}

variable "swan_eks_pod_identity_agent_eks_addon_version" {
  type = string
}

variable "swan_ci_role_arn" {
  type      = string
  sensitive = true
}