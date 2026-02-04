resource "helm_release" "swan_argocd_helm_release" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.4.0"
  namespace        = "argocd"
  create_namespace = true
}

# Argo CD Image Updater
resource "helm_release" "swan_argocd_image_updater_helm_release" {
  name = "argocd-image-updater"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-image-updater"
  version          = "1.0.5"
  namespace        = "argocd"
  create_namespace = true

  values = [
    templatefile("${path.module}/swan_values/argocd-image-updater-values.yaml.tpl", {
      swan_aws_region   = var.swan_aws_region
      swan_ecr_registry = var.swan_ecr_registry
    })
  ]

  depends_on = [helm_release.swan_argocd_helm_release]
}

resource "aws_iam_role" "swan_argocd_image_updater_role" {
  name = "${var.swan_eks_cluster_name}-swan_argocd_image_updater_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "swan_argocd_image_updater_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.swan_argocd_image_updater_role.name
}

resource "aws_eks_pod_identity_association" "swan_argocd_image_updater_pod_identity_association" {
  cluster_name    = var.swan_eks_cluster_name
  namespace       = "argocd"
  service_account = "argocd-image-updater"
  role_arn        = aws_iam_role.swan_argocd_image_updater_role.arn
}