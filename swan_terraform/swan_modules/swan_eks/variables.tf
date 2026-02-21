variable "swan_eks_cluster_name" {
  type = string
}

variable "swan_eks_cluster_version" {
  type = string
}

variable "swan_private_subnet_ids" {
  type = list(string)
}

variable "swan_system_eks_node_group_instance_types" {
  type = list(string)
}

variable "swan_system_eks_node_group_desired_size" {
  type = string
}

variable "swan_system_eks_node_group_min_size" {
  type = string
}

variable "swan_system_eks_node_group_max_size" {
  type = string
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

variable "swan_ci_iam_role_arn" {
  type      = string
  sensitive = true
}