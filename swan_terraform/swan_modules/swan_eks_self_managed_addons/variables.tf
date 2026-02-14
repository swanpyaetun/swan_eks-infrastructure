variable "swan_aws_region" {
  type = string
}

variable "swan_ecr_registry" {
  type      = string
  sensitive = true
}

variable "swan_eks_cluster_name" {
  type = string
}

variable "swan_vpc_id" {
  type = string
}