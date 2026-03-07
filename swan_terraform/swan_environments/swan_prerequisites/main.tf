################################################################################
# Prerequisites for swanpyaetun/swan_eks-infrastructure Project
################################################################################

# GitHub OIDC provider
resource "aws_iam_openid_connect_provider" "swan_github_oidc_provider" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

# CI IAM Role for swanpyaetun/swan_eks-infrastructure Project
resource "aws_iam_role" "swan_githubactions_terraform_iam_role" {
  name = "swan_githubactions_terraform_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.swan_github_oidc_provider.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:swanpyaetun/swan_eks-infrastructure:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "swan_githubactions_terraform_iam_role_policy_attachment" {
  role       = aws_iam_role.swan_githubactions_terraform_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# S3 Bucket
module "swan_s3" {
  source              = "../../swan_modules/swan_s3"
  swan_s3_bucket_name = var.swan_s3_bucket_name
}

################################################################################
# Prerequisites for swanpyaetun/swan_polyglot-microservices-application Project
################################################################################

# CI IAM Role for swanpyaetun/swan_polyglot-microservices-application Project
resource "aws_iam_role" "swan_githubactions_ecr_iam_role" {
  name = "swan_githubactions_ecr_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.swan_github_oidc_provider.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:swanpyaetun/swan_polyglot-microservices-application:*"
          }
        }
      }
    ]
  })

  tags = {
    Project = "swan_polyglot-microservices-application"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role_policy" "swan_githubactions_ecr_iam_role_policy" {
  name = "swan_githubactions_ecr_iam_role_policy"
  role = aws_iam_role.swan_githubactions_ecr_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Statement1"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "Statement2"
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = "arn:aws:ecr:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:repository/${var.swan_private_ecr_namespace}/*"
        Resource = [
          for repo in var.swan_private_ecr_repository_names :
          "arn:aws:ecr:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:repository/${var.swan_private_ecr_namespace}/${repo}"
        ]
      }
    ]
  })
}

# Private ECR Repositories
module "swan_ecr" {
  source                            = "../../swan_modules/swan_ecr"
  swan_private_ecr_namespace        = var.swan_private_ecr_namespace
  swan_private_ecr_repository_names = var.swan_private_ecr_repository_names
}

# ACM Certificate
module "swan_acm" {
  source                                         = "../../swan_modules/swan_acm"
  swan_domain_name                               = var.swan_domain_name
  swan_acm_certificate_subject_alternative_names = var.swan_acm_certificate_subject_alternative_names
}