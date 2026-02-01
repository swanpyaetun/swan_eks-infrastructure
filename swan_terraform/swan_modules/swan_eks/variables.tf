variable "swan_eks_cluster_name" {
  type = string
}

variable "swan_eks_cluster_version" {
  type = string
}

variable "swan_private_subnet_ids" {
  type = list(string)
}

variable "swan_eks_addons" {
  type = map(object({
    addon_version = string
  }))
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

variable "swan_aws_account_id" {
  type      = string
  sensitive = true
}