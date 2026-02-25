# CI IAM Role
resource "aws_eks_access_entry" "swan_ci_iam_role_access_entry" {
  principal_arn = var.swan_ci_iam_role_arn
  cluster_name  = aws_eks_cluster.swan_eks_cluster.name
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "swan_ci_iam_role_access_policy_association" {
  principal_arn = var.swan_ci_iam_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  cluster_name  = aws_eks_cluster.swan_eks_cluster.name
  access_scope {
    type = "cluster"
  }
}

# EKS Cluster Admin IAM Role
resource "aws_iam_role" "swan_eks_cluster_admin_iam_role" {
  name = "${var.swan_eks_cluster_name}-swan_eks_cluster_admin_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "swan_eks_cluster_admin_iam_role_policy" {
  name = "${var.swan_eks_cluster_name}-swan_eks_cluster_admin_iam_role_policy"
  role = aws_iam_role.swan_eks_cluster_admin_iam_role.name

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

resource "aws_eks_access_entry" "swan_eks_cluster_admin_iam_role_access_entry" {
  principal_arn = aws_iam_role.swan_eks_cluster_admin_iam_role.arn
  cluster_name  = aws_eks_cluster.swan_eks_cluster.name
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "swan_eks_cluster_admin_iam_role_access_policy_association" {
  principal_arn = aws_iam_role.swan_eks_cluster_admin_iam_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  cluster_name  = aws_eks_cluster.swan_eks_cluster.name
  access_scope {
    type = "cluster"
  }
}