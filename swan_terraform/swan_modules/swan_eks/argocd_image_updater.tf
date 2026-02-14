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
  depends_on = [ aws_eks_cluster.swan_eks_cluster ]
}