resource "helm_release" "swan_sealed_secrets_helm_release" {
  name       = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets/"
  chart      = "sealed-secrets"
  version    = "2.18.1"
  namespace  = "kube-system"
  values     = [file("${path.module}/swan_helm_values/sealed-secrets.yaml")]
}

resource "helm_release" "swan_argocd_helm_release" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.4.4"
  namespace        = "argocd"
  create_namespace = true
  values           = [file("${path.module}/swan_helm_values/argocd.yaml")]
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "helm_release" "swan_argocd_image_updater_helm_release" {
  name = "argocd-image-updater"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"
  version    = "1.1.1"
  namespace  = "argocd"

  values = [
    templatefile("${path.module}/swan_helm_values/argocd-image-updater.yaml.tpl", {
      swan_aws_account_id = data.aws_caller_identity.current.account_id
      swan_aws_region     = data.aws_region.current.id
    })
  ]

  depends_on = [helm_release.swan_argocd_helm_release]
}

resource "helm_release" "swan_aws_load_balancer_controller_helm_release" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.1.0"
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/swan_helm_values/aws-load-balancer-controller.yaml.tpl", {
      swan_eks_cluster_name = var.swan_eks_cluster_name
      swan_vpc_id           = var.swan_vpc_id
    })
  ]
}

resource "helm_release" "swan_metrics_server_helm_release" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.13.0"
  namespace  = "kube-system"
  values     = [file("${path.module}/swan_helm_values/metrics-server.yaml")]
}

data "aws_ecrpublic_authorization_token" "token" {
  region = "us-east-1"
}

resource "helm_release" "swan_karpenter_helm_release" {
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "1.9.0"
  namespace           = "kube-system"

  values = [
    templatefile("${path.module}/swan_helm_values/karpenter.yaml.tpl", {
      swan_eks_cluster_name                      = var.swan_eks_cluster_name
      swan_eks_cluster_endpoint                  = var.swan_eks_cluster_endpoint
      swan_karpenter_interruption_sqs_queue_name = var.swan_karpenter_interruption_sqs_queue_name
    })
  ]
}