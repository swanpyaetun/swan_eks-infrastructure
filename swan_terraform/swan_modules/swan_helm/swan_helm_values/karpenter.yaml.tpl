---
serviceAccount:
  name: karpenter

settings:
  clusterName: ${swan_eks_cluster_name}
  clusterEndpoint: ${swan_eks_cluster_endpoint}
  interruptionQueue: ${swan_karpenter_interruption_sqs_queue_name}