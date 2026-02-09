# EKS Cluster IAM Role
resource "aws_iam_role" "swan_eks_cluster_role" {
  name = "${var.swan_eks_cluster_name}-swan_eks_cluster_role"

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

resource "aws_iam_role_policy_attachment" "swan_eks_cluster_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.swan_eks_cluster_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "swan_eks_cluster" {
  name     = var.swan_eks_cluster_name
  role_arn = aws_iam_role.swan_eks_cluster_role.arn
  version  = var.swan_eks_cluster_version

  vpc_config {
    subnet_ids              = var.swan_private_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.swan_eks_cluster_role_policy_attachment
  ]
}

# EKS add-ons
resource "aws_eks_addon" "swan_eks_addons" {
  for_each                    = { for addon in var.swan_eks_addons : addon.addon_name => addon }
  cluster_name                = aws_eks_cluster.swan_eks_cluster.name
  addon_name                  = each.value.addon_name
  addon_version               = each.value.addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values        = try(each.value.configuration_values, null)
}

# EKS Node Groups IAM Role
resource "aws_iam_role" "swan_eks_node_role" {
  name = "${var.swan_eks_cluster_name}-swan_eks_node_role"

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

resource "aws_iam_role_policy_attachment" "swan_eks_node_role_policy_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  policy_arn = each.value
  role       = aws_iam_role.swan_eks_node_role.name
}

# EKS Node Groups
resource "aws_eks_node_group" "swan_eks_node_groups" {
  for_each        = var.swan_eks_node_groups
  cluster_name    = aws_eks_cluster.swan_eks_cluster.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.swan_eks_node_role.arn
  subnet_ids      = var.swan_private_subnet_ids
  instance_types  = each.value.instance_types
  capacity_type   = each.value.capacity_type

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    min_size     = each.value.scaling_config.min_size
    max_size     = each.value.scaling_config.max_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.swan_eks_node_role_policy_attachment
  ]
}