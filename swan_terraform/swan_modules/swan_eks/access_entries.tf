# CI Role
resource "aws_eks_access_entry" "swan_ci_role_access_entry" {
  cluster_name  = aws_eks_cluster.swan_eks_cluster.name
  principal_arn = var.swan_ci_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "swan_ci_role_access_policy_association" {
  cluster_name  = aws_eks_cluster.swan_eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.swan_ci_role_arn
  access_scope {
    type = "cluster"
  }
}

# EKS Cluster Admin IAM Role
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "swan_eks_cluster_admin_role" {
  name = "${var.swan_eks_cluster_name}-swan_eks_cluster_admin_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
    }]
  })
}

resource "aws_iam_policy" "swan_eks_cluster_admin_policy" {
  name = "swan_eks_cluster_admin_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "eks.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "swan_eks_cluster_admin_policy_attachment" {
  role       = aws_iam_role.swan_eks_cluster_admin_role.name
  policy_arn = aws_iam_policy.swan_eks_cluster_admin_policy.arn
}

resource "aws_eks_access_entry" "swan_eks_cluster_admin_role_access_entry" {
  cluster_name  = aws_eks_cluster.swan_eks_cluster.name
  principal_arn = aws_iam_role.swan_eks_cluster_admin_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "swan_eks_cluster_admin_role_access_policy_association" {
  cluster_name  = aws_eks_cluster.swan_eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.swan_eks_cluster_admin_role.arn
  access_scope {
    type = "cluster"
  }
}