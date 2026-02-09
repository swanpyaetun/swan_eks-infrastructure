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
  type = list(object({
    addon_name           = string
    addon_version        = string
    configuration_values = optional(string)
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

variable "swan_ci_role_arn" {
  type      = string
  sensitive = true
}

variable "swan_eks_cluster_admin_user_arn" {
  type      = string
  sensitive = true
}