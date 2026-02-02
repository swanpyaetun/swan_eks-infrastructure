variable "swan_region" {
  type = string
}

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

variable "swan_eks_cluster_name" {
  type = string
}

variable "swan_eks_cluster_version" {
  type = string
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

variable "swan_ci_role_arn" {
  type      = string
  sensitive = true
}

variable "swan_user_arn" {
  type      = string
  sensitive = true
}