data "aws_route53_zone" "public" {
  name         = "devtool.site"
  private_zone = false
}

resource "aws_acm_certificate" "api" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "my_validation_record" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = tolist(aws_acm_certificate.api.domain_validation_options)[0].resource_record_name
  records = [tolist(aws_acm_certificate.api.domain_validation_options)[0].resource_record_value]
  type    = tolist(aws_acm_certificate.api.domain_validation_options)[0].resource_record_type
  ttl     = var.ttl
}

resource "aws_route53_record" "my_cname_record" {
  zone_id    = data.aws_route53_zone.public.zone_id
  name       = var.domain_name
  type       = "CNAME"
  records    = [aws_alb.main.dns_name]
  ttl        = var.ttl
  depends_on = [aws_alb.main]
}

resource "aws_acm_certificate_validation" "my_certificate_validation" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [aws_route53_record.my_validation_record.fqdn]
}

