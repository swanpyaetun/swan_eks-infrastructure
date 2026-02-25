# Private ECR Repositories
resource "aws_ecr_repository" "swan_private_ecr_repositories" {
  for_each     = toset(var.swan_private_ecr_repository_names)
  name         = "${var.swan_private_ecr_namespace}/${each.value}"
  force_delete = true

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "swan_ecr_lifecycle_policies" {
  for_each   = aws_ecr_repository.swan_private_ecr_repositories
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Basic Scanning
resource "aws_ecr_registry_scanning_configuration" "swan_private_ecr_registry_scanning_configuration" {
  scan_type = "BASIC"

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "${var.swan_private_ecr_namespace}/*"
      filter_type = "WILDCARD"
    }
  }
}