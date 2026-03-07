output "swan_githubactions_terraform_iam_role_arn" {
  value = aws_iam_role.swan_githubactions_terraform_iam_role.arn
}

output "swan_githubactions_ecr_iam_role_arn" {
  value = aws_iam_role.swan_githubactions_ecr_iam_role.arn
}

output "swan_acm_certificate_arn" {
  value = module.swan_acm.swan_acm_certificate_arn
}