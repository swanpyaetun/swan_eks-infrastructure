variable "swan_vpc_id" {
  type = string
}

variable "swan_eks_cluster_name" {
  type = string
}

variable "swan_eks_cluster_endpoint" {
  type      = string
  sensitive = true
}

variable "swan_karpenter_interruption_sqs_queue_name" {
  type = string
}