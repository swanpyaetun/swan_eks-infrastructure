---
serviceAccount:
  name: karpenter

settings:
  clusterName: ${var.swan_eks_cluster_name}
  clusterEndpoint: ${var.swan_eks_cluster_endpoint}
  interruptionQueue: ${var.swan_karpenter_interruption_sqs_queue_name}