resource "helm_release" "swan_sealed_secrets_helm_release" {
  name             = "sealed-secrets"
  repository       = "https://bitnami-labs.github.io/sealed-secrets/"
  chart            = "sealed-secrets"
  version          = "2.18.1"
  namespace        = "kube-system"
  create_namespace = true
}

resource "helm_release" "swan_argocd_helm_release" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.4.1"
  namespace        = "argocd"
  create_namespace = true
}

resource "helm_release" "swan_argocd_image_updater_helm_release" {
  name = "argocd-image-updater"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-image-updater"
  version          = "1.1.0"
  namespace        = "argocd"
  create_namespace = true

  values = [
    templatefile("${path.module}/swan_values/argocd-image-updater.yaml.tpl", {
      swan_aws_region   = var.swan_aws_region
      swan_ecr_registry = var.swan_ecr_registry
    })
  ]

  depends_on = [helm_release.swan_argocd_helm_release]
}

resource "helm_release" "swan_aws_load_balancer_controller_helm_release" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.0.0"
  namespace  = "kube-system"

  set = [
    {
      name  = "clusterName"
      value = var.swan_eks_cluster_name
      }, {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
      }, {
      name  = "vpcId"
      value = var.swan_vpc_id
  }]
}

resource "helm_release" "swan_metrics_server_helm_release" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.13.0"
  namespace  = "kube-system"
}