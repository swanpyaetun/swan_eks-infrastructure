# EKS Cluster IAM Role
resource "aws_iam_role" "swan_eks_cluster_iam_role" {
  name = "${var.swan_eks_cluster_name}-swan_eks_cluster_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "swan_eks_cluster_iam_role_policy_attachment" {
  role       = aws_iam_role.swan_eks_cluster_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Cluster
resource "aws_eks_cluster" "swan_eks_cluster" {
  name     = var.swan_eks_cluster_name
  role_arn = aws_iam_role.swan_eks_cluster_iam_role.arn
  version  = var.swan_eks_cluster_version

  vpc_config {
    subnet_ids              = var.swan_private_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.swan_eks_cluster_iam_role_policy_attachment
  ]
}

# EKS Node IAM Role
resource "aws_iam_role" "swan_eks_node_iam_role" {
  name = "${var.swan_eks_cluster_name}-swan_eks_node_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "swan_eks_node_iam_role_policy_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  role       = aws_iam_role.swan_eks_node_iam_role.name
  policy_arn = each.value
}

# System EKS Node Group
resource "aws_eks_node_group" "swan_system_eks_node_group" {
  cluster_name    = aws_eks_cluster.swan_eks_cluster.name
  node_group_name = "${var.swan_eks_cluster_name}-swan_system_eks_node_group"
  node_role_arn   = aws_iam_role.swan_eks_node_iam_role.arn
  subnet_ids      = var.swan_private_subnet_ids
  capacity_type   = "ON_DEMAND"
  instance_types  = var.swan_system_eks_node_group_instance_types

  scaling_config {
    desired_size = var.swan_system_eks_node_group_desired_size
    min_size     = var.swan_system_eks_node_group_min_size
    max_size     = var.swan_system_eks_node_group_max_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    system = "true"
  }

  taint {
    key    = "system"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  depends_on = [
    aws_iam_role_policy_attachment.swan_eks_node_iam_role_policy_attachment
  ]
}