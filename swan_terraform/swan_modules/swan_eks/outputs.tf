output "swan_eks_cluster_endpoint" {
  value     = aws_eks_cluster.swan_eks_cluster.endpoint
  sensitive = true
}

output "swan_eks_cluster_certificate_authority_data" {
  value     = aws_eks_cluster.swan_eks_cluster.certificate_authority[0].data
  sensitive = true
}

data "aws_eks_cluster_auth" "swan_eks_cluster_auth" {
  name = aws_eks_cluster.swan_eks_cluster.name
}

output "swan_eks_cluster_auth_token" {
  value     = data.aws_eks_cluster_auth.swan_eks_cluster_auth.token
  sensitive = true
}

output "swan_karpenter_interruption_sqs_queue_name" {
  value = aws_sqs_queue.swan_karpenter_interruption_sqs_queue.name
}