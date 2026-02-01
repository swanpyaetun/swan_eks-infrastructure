resource "helm_release" "swan_lbc_helm_release" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.0.0"
  namespace  = "kube-system"

  set = [
    {
      name  = "clusterName"
      value = aws_eks_cluster.swan_eks_cluster.name
      }, {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
      }, {
      name  = "vpcId"
      value = var.swan_vpc_id
  }]
}

resource "aws_iam_role" "swan_lbc_role" {
  name = "${aws_eks_cluster.swan_eks_cluster.name}-swan_lbc_role"
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

resource "aws_iam_policy" "swan_lbc_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("AWSLoadBalancerControllerIAMPolicy.json")
}

resource "aws_iam_role_policy_attachment" "swan_lbc_role_policy_attachment" {
  policy_arn = aws_iam_policy.swan_lbc_policy.arn
  role       = aws_iam_role.swan_lbc_role.name
}

resource "aws_eks_pod_identity_association" "swan_lbc_pod_identity_association" {
  cluster_name    = aws_eks_cluster.swan_eks_cluster.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.swan_lbc_role.arn
}