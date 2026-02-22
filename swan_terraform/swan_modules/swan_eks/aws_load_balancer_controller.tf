# AWS Load Balancer Controller IAM Role
resource "aws_iam_role" "swan_aws_load_balancer_controller_iam_role" {
  name = "${var.swan_eks_cluster_name}-swan_aws_load_balancer_controller_iam_role"

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

resource "aws_iam_role_policy" "swan_aws_load_balancer_controller_iam_role_policy" {
  name   = "${var.swan_eks_cluster_name}-swan_aws_load_balancer_controller_iam_role_policy"
  role   = aws_iam_role.swan_aws_load_balancer_controller_iam_role.name
  policy = file("${path.module}/swan_iam_role_policies/swan_aws_load_balancer_controller_iam_role_policy.json")
}

resource "aws_eks_pod_identity_association" "swan_aws_load_balancer_controller_pod_identity_association" {
  role_arn        = aws_iam_role.swan_aws_load_balancer_controller_iam_role.arn
  cluster_name    = aws_eks_cluster.swan_eks_cluster.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  depends_on      = [aws_eks_addon.swan_eks_pod_identity_agent_eks_addon]
}