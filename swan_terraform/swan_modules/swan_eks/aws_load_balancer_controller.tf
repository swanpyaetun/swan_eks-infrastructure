resource "aws_iam_role" "swan_aws_load_balancer_controller_role" {
  name = "${var.swan_eks_cluster_name}-swan_aws_lb_controller_role"
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

resource "aws_iam_policy" "swan_aws_load_balancer_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/swan_iam_policies/AWSLoadBalancerControllerIAMPolicy.json")
}

resource "aws_iam_role_policy_attachment" "swan_aws_load_balancer_controller_role_policy_attachment" {
  policy_arn = aws_iam_policy.swan_aws_load_balancer_controller_policy.arn
  role       = aws_iam_role.swan_aws_load_balancer_controller_role.name
}

resource "aws_eks_pod_identity_association" "swan_aws_load_balancer_controller_pod_identity_association" {
  cluster_name    = var.swan_eks_cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.swan_aws_load_balancer_controller_role.arn
}