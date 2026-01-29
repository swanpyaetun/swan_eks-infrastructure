# EKS Cluster IAM Role
resource "aws_iam_role" "swan_eks_cluster_role" {
  name = "${var.swan_eks_cluster_name}-swan_eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
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

# KMS key for EKS secrets encryption in etcd
resource "aws_kms_key" "swan_kms_key" {
  description             = "KMS key for EKS cluster ${var.swan_eks_cluster_name} secrets encryption in etcd"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "swan_kms_alias" {
  name          = "alias/${var.swan_eks_cluster_name}-swan_kms_key"
  target_key_id = aws_kms_key.swan_kms_key.key_id
}

# EKS Cluster
resource "aws_eks_cluster" "swan_eks_cluster" {
  name     = var.swan_eks_cluster_name
  role_arn = aws_iam_role.swan_eks_cluster_role.arn
  version  = var.swan_eks_cluster_version

  vpc_config {
    subnet_ids              = var.swan_private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.swan_kms_key.arn
    }
    resources = ["secrets"]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.swan_eks_cluster_role_policy_attachment
  ]
}

# EKS Node Groups IAM Role
resource "aws_iam_role" "swan_eks_node_role" {
  name = "${var.swan_eks_cluster_name}-swan_eks_node_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
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
  capacity_type   = lookup(each.value, "capacity_type", "ON_DEMAND")

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    min_size     = each.value.scaling_config.min_size
    max_size     = each.value.scaling_config.max_size
  }

  labels = lookup(each.value, "labels", {})

  dynamic "taint" {
    for_each = coalesce(lookup(each.value, "taints", null), [])
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = lookup(each.value, "tags", {})

  depends_on = [
    aws_iam_role_policy_attachment.swan_eks_node_role_policy_attachment
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# EKS Cluster Admin IAM Role
resource "aws_iam_role" "swan_eks_cluster_admin_role" {
  name = "${var.swan_eks_cluster_name}-swan_eks_cluster_admin_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.swan_aws_account_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_eks_access_entry" "swan_eks_access_entry" {
  cluster_name  = aws_eks_cluster.swan_eks_cluster.name
  principal_arn = aws_iam_role.swan_eks_cluster_admin_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "swan_eks_access_policy_association" {
  cluster_name  = aws_eks_cluster.swan_eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.swan_eks_cluster_admin_role.arn
  access_scope {
    type = "cluster"
  }
}