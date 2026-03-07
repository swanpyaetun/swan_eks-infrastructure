variable "swan_domain_name" {
  type = string
}

variable "swan_acm_certificate_subject_alternative_names" {
  type = list(string)
}