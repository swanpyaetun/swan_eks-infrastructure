---
serviceAccount:
  name: aws-load-balancer-controller

nodeSelector:
  system: "true"

tolerations:
- key: "system"
  operator: "Equal"
  value: "true"
  effect: "NoSchedule"

clusterName: ${swan_eks_cluster_name}

vpcId: ${swan_vpc_id}