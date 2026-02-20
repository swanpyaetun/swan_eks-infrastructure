# Argo CD Image Updater IAM Role
resource "aws_iam_role" "swan_argocd_image_updater_iam_role" {
  name = "${var.swan_eks_cluster_name}-swan_argocd_image_updater_iam_role"

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

resource "aws_iam_role_policy_attachment" "swan_argocd_image_updater_iam_role_policy_attachment" {
  role       = aws_iam_role.swan_argocd_image_updater_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_pod_identity_association" "swan_argocd_image_updater_pod_identity_association" {
  role_arn        = aws_iam_role.swan_argocd_image_updater_iam_role.arn
  cluster_name    = aws_eks_cluster.swan_eks_cluster.name
  namespace       = "argocd"
  service_account = "argocd-image-updater"
  depends_on      = [aws_eks_addon.swan_eks_pod_identity_agent_eks_addon]
}