resource "aws_iam_role" "swan_karpenter_iam_role" {
  name = "${var.swan_eks_cluster_name}-swan_karpenter_iam_role"

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

resource "aws_iam_role_policy" "swan_karpenter_iam_role_policy" {
  name   = "${var.swan_eks_cluster_name}-swan_karpenter_iam_role_policy"
  role   = aws_iam_role.swan_karpenter_iam_role.name
  policy = data.aws_iam_policy_document.swan_karpenter_iam_policy_document.json
}

resource "aws_eks_pod_identity_association" "swan_karpenter_pod_identity_association" {
  role_arn        = aws_iam_role.swan_karpenter_iam_role.arn
  cluster_name    = aws_eks_cluster.swan_eks_cluster.name
  namespace       = "kube-system"
  service_account = "karpenter"
  depends_on      = [aws_eks_addon.swan_eks_pod_identity_agent_eks_addon]
}

data "aws_iam_policy_document" "swan_karpenter_iam_policy_document" {

  # ==========================================================
  # 1. EC2 NODE LIFECYCLE
  # ==========================================================

  statement {
    sid     = "AllowScopedEC2InstanceAccessActions"
    effect  = "Allow"
    actions = ["ec2:RunInstances", "ec2:CreateFleet"]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.id}::image/*",
      "arn:aws:ec2:${data.aws_region.current.id}::snapshot/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:security-group/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:subnet/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:capacity-reservation/*"
    ]
  }

  statement {
    sid     = "AllowScopedEC2LaunchTemplateAccessActions"
    effect  = "Allow"
    actions = ["ec2:RunInstances", "ec2:CreateFleet"]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.id}:*:launch-template/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.swan_eks_cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  statement {
    sid     = "AllowScopedEC2InstanceActionsWithTags"
    effect  = "Allow"
    actions = ["ec2:RunInstances", "ec2:CreateFleet", "ec2:CreateLaunchTemplate"]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.id}:*:fleet/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:instance/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:volume/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:network-interface/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:launch-template/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:spot-instances-request/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.swan_eks_cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [var.swan_eks_cluster_name]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  statement {
    sid     = "AllowScopedResourceCreationTagging"
    effect  = "Allow"
    actions = ["ec2:CreateTags"]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.id}:*:fleet/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:instance/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:volume/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:network-interface/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:launch-template/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:spot-instances-request/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.swan_eks_cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [var.swan_eks_cluster_name]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["RunInstances", "CreateFleet", "CreateLaunchTemplate"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  statement {
    sid     = "AllowScopedResourceTagging"
    effect  = "Allow"
    actions = ["ec2:CreateTags"]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.id}:*:instance/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.swan_eks_cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }

    condition {
      test     = "StringEqualsIfExists"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [var.swan_eks_cluster_name]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values = [
        "eks:eks-cluster-name",
        "karpenter.sh/nodeclaim",
        "Name"
      ]
    }
  }

  statement {
    sid     = "AllowScopedDeletion"
    effect  = "Allow"
    actions = ["ec2:TerminateInstances", "ec2:DeleteLaunchTemplate"]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.id}:*:instance/*",
      "arn:aws:ec2:${data.aws_region.current.id}:*:launch-template/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.swan_eks_cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  # ==========================================================
  # 2. IAM INTEGRATION
  # ==========================================================

  statement {
    sid       = "AllowPassingInstanceRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.swan_eks_nodes_iam_role.arn]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com", "ec2.amazonaws.com.cn"]
    }
  }

  statement {
    sid     = "AllowScopedInstanceProfileCreationActions"
    effect  = "Allow"
    actions = ["iam:CreateInstanceProfile"]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.swan_eks_cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [var.swan_eks_cluster_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/topology.kubernetes.io/region"
      values   = [data.aws_region.current.id]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  statement {
    sid     = "AllowScopedInstanceProfileTagActions"
    effect  = "Allow"
    actions = ["iam:TagInstanceProfile"]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.swan_eks_cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [data.aws_region.current.id]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  statement {
    sid    = "AllowScopedInstanceProfileActions"
    effect = "Allow"
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:DeleteInstanceProfile"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.swan_eks_cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [data.aws_region.current.id]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  # ==========================================================
  # 3. EKS CLUSTER DISCOVERY
  # ==========================================================

  statement {
    sid     = "AllowAPIServerEndpointDiscovery"
    effect  = "Allow"
    actions = ["eks:DescribeCluster"]

    resources = [
      "arn:aws:eks:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:cluster/${var.swan_eks_cluster_name}"
    ]
  }

  # ==========================================================
  # 4. SQS INTERRUPTION HANDLING
  # ==========================================================

  statement {
    sid    = "AllowInterruptionQueueActions"
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage"
    ]

    resources = [aws_sqs_queue.swan_karpenter_interruption_sqs_queue.arn]
  }

  # ==========================================================
  # 5. RESOURCE DISCOVERY
  # ==========================================================

  statement {
    sid    = "AllowRegionalReadActions"
    effect = "Allow"

    actions = [
      "ec2:DescribeCapacityReservations",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [data.aws_region.current.id]
    }
  }

  statement {
    sid     = "AllowSSMReadActions"
    effect  = "Allow"
    actions = ["ssm:GetParameter"]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.id}::parameter/aws/service/*"
    ]
  }

  statement {
    sid       = "AllowPricingReadActions"
    effect    = "Allow"
    actions   = ["pricing:GetProducts"]
    resources = ["*"]
  }

  statement {
    sid       = "AllowUnscopedInstanceProfileListAction"
    effect    = "Allow"
    actions   = ["iam:ListInstanceProfiles"]
    resources = ["*"]
  }

  statement {
    sid     = "AllowInstanceProfileReadActions"
    effect  = "Allow"
    actions = ["iam:GetInstanceProfile"]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
    ]
  }
}

# SQS Queue
resource "aws_sqs_queue" "swan_karpenter_interruption_sqs_queue" {
  name                      = "${var.swan_eks_cluster_name}-swan_karpenter_interruption_sqs_queue"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true
}

resource "aws_sqs_queue_policy" "swan_karpenter_interruption_sqs_queue_policy" {
  queue_url = aws_sqs_queue.swan_karpenter_interruption_sqs_queue.id

  policy = jsonencode({
    Version = "2012-10-17" # Version is set to avoid AWS hang
    Id      = "EC2InterruptionPolicy"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "events.amazonaws.com",
            "sqs.amazonaws.com"
          ]
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.swan_karpenter_interruption_sqs_queue.arn
      },
      {
        Sid       = "DenyHTTP"
        Effect    = "Deny"
        Action    = "sqs:*"
        Resource  = aws_sqs_queue.swan_karpenter_interruption_sqs_queue.arn
        Principal = "*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# EventBridge Rules
locals {
  swan_events = {
    swan_health_event_eventbridge_rule = {
      name        = "swan_health_event_eventbridge_rule"
      description = "Karpenter interrupt - AWS health event"
      event_pattern = {
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
      }
    }
    swan_spot_interruption_eventbridge_rule = {
      name        = "swan_spot_interruption_eventbridge_rule"
      description = "Karpenter interrupt - EC2 spot instance interruption warning"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
    swan_instance_rebalance_eventbridge_rule = {
      name        = "swan_instance_rebalance_eventbridge_rule"
      description = "Karpenter interrupt - EC2 instance rebalance recommendation"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      }
    }
    swan_instance_state_change_eventbridge_rule = {
      name        = "swan_instance_state_change_eventbridge_rule"
      description = "Karpenter interrupt - EC2 instance state-change notification"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
      }
    }
  }
}

resource "aws_cloudwatch_event_rule" "swan_eventbridge_rules" {
  for_each      = local.swan_events
  name          = each.value.name
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)
}

resource "aws_cloudwatch_event_target" "swan_eventbridge_target" {
  for_each  = local.swan_events
  rule      = aws_cloudwatch_event_rule.swan_eventbridge_rules[each.key].name
  target_id = "swan_karpenter_interruption_sqs_queue_target"
  arn       = aws_sqs_queue.swan_karpenter_interruption_sqs_queue.arn
}