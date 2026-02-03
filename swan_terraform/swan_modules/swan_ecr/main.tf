resource "aws_ecr_repository" "swan_ecr_repositories" {
  for_each = toset(var.swan_ecr_repository_names)
  name     = "${var.swan_ecr_namespace}/${each.value}"
}

resource "aws_ecr_lifecycle_policy" "swan_ecr_lifecycle_policy" {
  for_each   = aws_ecr_repository.swan_ecr_repositories
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = [""],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}