variable "swan_vpc_cidr_block" {
  type = string
}

variable "swan_private_subnet_cidr_blocks" {
  type = list(string)
}

variable "swan_eks_cluster_name" {
  type = string
}