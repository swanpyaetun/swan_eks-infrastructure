# External DNS IAM Role
resource "aws_iam_role" "swan_external_dns_iam_role" {
  name = "${var.swan_eks_cluster_name}-swan_external_dns_iam_role"

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

resource "aws_iam_role_policy" "swan_external_dns_iam_role_policy" {
  name = "${var.swan_eks_cluster_name}-swan_external_dns_iam_role_policy"
  role = aws_iam_role.swan_external_dns_iam_role.name
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets",
            "route53:ListTagsForResources"
          ],
          "Resource" : [
            "arn:aws:route53:::hostedzone/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ListHostedZones"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    }
  )
}

resource "aws_eks_pod_identity_association" "swan_external_dns_pod_identity_association" {
  role_arn        = aws_iam_role.swan_external_dns_iam_role.arn
  cluster_name    = aws_eks_cluster.swan_eks_cluster.name
  namespace       = "kube-system"
  service_account = "external-dns"
  depends_on      = [aws_eks_addon.swan_eks_pod_identity_agent_eks_addon]
}