# swan_s3
swan_s3_bucket_name = "swan-terraform-backend"

# swan_ecr
swan_private_ecr_namespace = "swan_polyglot-microservices-application"
swan_private_ecr_repository_names = [
  "accounting",
  "ad",
  "cart",
  "checkout",
  "currency",
  "email",
  "flagd",
  "fraud-detection",
  "frontend",
  "frontend-proxy",
  "image-provider",
  "kafka",
  "llm",
  "load-generator",
  "payment",
  "product-catalog",
  "product-reviews",
  "quote",
  "recommendation",
  "shipping"
]

# swan_acm
swan_domain_name                               = "swanpyaetun.com"
swan_acm_certificate_subject_alternative_names = ["*.swanpyaetun.com"]