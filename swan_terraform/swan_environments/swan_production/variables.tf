# swan_ecr
variable "swan_ecr_namespace" {
  type = string
}

variable "swan_ecr_repository_names" {
  type = list(string)
}

# swan_vpc
variable "swan_vpc_cidr_block" {
  type = string
}

variable "swan_availability_zones" {
  type = list(string)
}

variable "swan_public_subnet_cidr_blocks" {
  type = list(string)
}

variable "swan_public_subnet_tags" {
  type    = map(string)
  default = {}
}

variable "swan_private_subnet_cidr_blocks" {
  type = list(string)
}

variable "swan_private_subnet_tags" {
  type    = map(string)
  default = {}
}

# swan_eks
variable "swan_eks_cluster_name" {
  type = string
}

variable "swan_eks_cluster_version" {
  type = string
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