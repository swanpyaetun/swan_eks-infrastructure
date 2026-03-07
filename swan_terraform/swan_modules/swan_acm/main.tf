# ACM Certificate
resource "aws_acm_certificate" "swan_acm_certificate" {
  domain_name               = var.swan_domain_name
  subject_alternative_names = var.swan_acm_certificate_subject_alternative_names
  options {
    export = "DISABLED"
  }
  validation_method = "DNS"
  key_algorithm     = "RSA_2048"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "swan_route53_public_hosted_zone" {
  name         = var.swan_domain_name
  private_zone = false
}

resource "aws_route53_record" "swan_acm_certificate_route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.swan_acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.swan_route53_public_hosted_zone.zone_id
}

resource "aws_acm_certificate_validation" "swan_acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.swan_acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.swan_acm_certificate_route53_record : record.fqdn]
}