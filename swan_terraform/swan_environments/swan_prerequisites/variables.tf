# swan_s3
variable "swan_s3_bucket_name" {
  type = string
}

# swan_ecr
variable "swan_private_ecr_namespace" {
  type = string
}

variable "swan_private_ecr_repository_names" {
  type = list(string)
}

# swan_acm
variable "swan_domain_name" {
  type = string
}

variable "swan_acm_certificate_subject_alternative_names" {
  type = list(string)
}