resource "aws_eks_addon" "swan_vpc_cni_eks_addon" {
  cluster_name                = aws_eks_cluster.swan_eks_cluster.name
  addon_name                  = "vpc-cni"
  addon_version               = var.swan_vpc_cni_eks_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
    }
    enableNetworkPolicy = "true"
    tolerations = [
      {
        key      = "system"
        operator = "Equal"
        value    = "true"
        effect   = "NoSchedule"
      }
    ]
  })
}

resource "aws_eks_addon" "swan_coredns_eks_addon" {
  cluster_name                = aws_eks_cluster.swan_eks_cluster.name
  addon_name                  = "coredns"
  addon_version               = var.swan_coredns_eks_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    nodeSelector = {
      system = "true"
    }
    tolerations = [
      {
        key      = "system"
        operator = "Equal"
        value    = "true"
        effect   = "NoSchedule"
      }
    ]
  })
}

resource "aws_eks_addon" "swan_kube_proxy_eks_addon" {
  cluster_name                = aws_eks_cluster.swan_eks_cluster.name
  addon_name                  = "kube-proxy"
  addon_version               = var.swan_kube_proxy_eks_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    tolerations = [
      {
        key      = "system"
        operator = "Equal"
        value    = "true"
        effect   = "NoSchedule"
      }
    ]
  })
}

resource "aws_eks_addon" "swan_eks_pod_identity_agent_eks_addon" {
  cluster_name                = aws_eks_cluster.swan_eks_cluster.name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = var.swan_eks_pod_identity_agent_eks_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    tolerations = [
      {
        key      = "system"
        operator = "Equal"
        value    = "true"
        effect   = "NoSchedule"
      }
    ]
  })
}