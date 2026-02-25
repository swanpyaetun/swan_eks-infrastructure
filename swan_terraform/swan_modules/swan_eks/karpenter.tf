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
        Sid      = "DenyHTTP"
        Effect   = "Deny"
        Action   = "sqs:*"
        Resource = aws_sqs_queue.swan_karpenter_interruption_sqs_queue.arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
        Principal = "*"
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

# Karpenter IAM Role
resource "aws_iam_role" "swan_karpenter_iam_role" {
  name = "${var.swan_eks_cluster_name}-swan_karpenter_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })
}

resource "aws_iam_role_policy" "swan_karpenter_node_lifecycle_iam_role_policy" {
  name = "${var.swan_eks_cluster_name}-swan_karpenter_node_lifecycle_iam_role_policy"
  role = aws_iam_role.swan_karpenter_iam_role.name
  policy = templatefile("${path.module}/swan_iam_role_policies/swan_karpenter_node_lifecycle_iam_role_policy.json.tpl", {
    swan_aws_region       = data.aws_region.current.id
    swan_eks_cluster_name = var.swan_eks_cluster_name
  })
}

resource "aws_iam_role_policy" "swan_karpenter_iam_integration_iam_role_policy" {
  name = "${var.swan_eks_cluster_name}-swan_karpenter_iam_integration_iam_role_policy"
  role = aws_iam_role.swan_karpenter_iam_role.name
  policy = templatefile("${path.module}/swan_iam_role_policies/swan_karpenter_iam_integration_iam_role_policy.json.tpl", {
    swan_aws_account_id        = data.aws_caller_identity.current.account_id
    swan_aws_region            = data.aws_region.current.id
    swan_eks_node_iam_role_arn = aws_iam_role.swan_eks_node_iam_role.arn
    swan_eks_cluster_name      = var.swan_eks_cluster_name
  })
}

resource "aws_iam_role_policy" "swan_karpenter_eks_integration_iam_role_policy" {
  name = "${var.swan_eks_cluster_name}-swan_karpenter_eks_integration_iam_role_policy"
  role = aws_iam_role.swan_karpenter_iam_role.name
  policy = templatefile("${path.module}/swan_iam_role_policies/swan_karpenter_eks_integration_iam_role_policy.json.tpl", {
    swan_aws_account_id   = data.aws_caller_identity.current.account_id
    swan_aws_region       = data.aws_region.current.id
    swan_eks_cluster_name = var.swan_eks_cluster_name
  })
}

resource "aws_iam_role_policy" "swan_karpenter_interruption_iam_role_policy" {
  name = "${var.swan_eks_cluster_name}-swan_karpenter_interruption_iam_role_policy"
  role = aws_iam_role.swan_karpenter_iam_role.name
  policy = templatefile("${path.module}/swan_iam_role_policies/swan_karpenter_interruption_iam_role_policy.json.tpl", {
    swan_karpenter_interruption_sqs_queue_arn = aws_sqs_queue.swan_karpenter_interruption_sqs_queue.arn
  })
}

resource "aws_iam_role_policy" "swan_karpenter_resource_discovery_iam_role_policy" {
  name = "${var.swan_eks_cluster_name}-swan_karpenter_resource_discovery_iam_role_policy"
  role = aws_iam_role.swan_karpenter_iam_role.name
  policy = templatefile("${path.module}/swan_iam_role_policies/swan_karpenter_resource_discovery_iam_role_policy.json.tpl", {
    swan_aws_account_id = data.aws_caller_identity.current.account_id
    swan_aws_region     = data.aws_region.current.id
  })
}

resource "aws_eks_pod_identity_association" "swan_karpenter_pod_identity_association" {
  role_arn        = aws_iam_role.swan_karpenter_iam_role.arn
  cluster_name    = aws_eks_cluster.swan_eks_cluster.name
  namespace       = "kube-system"
  service_account = "karpenter"
  depends_on      = [aws_eks_addon.swan_eks_pod_identity_agent_eks_addon]
}