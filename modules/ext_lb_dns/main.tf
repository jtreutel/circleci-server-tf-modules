
#-------------------------------------------------------------------------------
# DNS RECORDS
#-------------------------------------------------------------------------------


#dummy record to allow for short ttlzs
resource "aws_route53_record" "root_A" {
  count = var.server_subdomain == "" ? 1 : 0

  zone_id = data.aws_route53_zone.circleci.zone_id
  name    = var.server_fqdn
  type    = "A"
  ttl     = var.r53_ttl
  records = ["192.0.2.0"]
}

resource "aws_route53_record" "root_ALIAS" {
  count = var.server_subdomain != "" ? 1 : 0

  zone_id = data.aws_route53_zone.circleci.zone_id
  name    = var.server_fqdn
  type    = "A"

  alias {
    name                   = data.aws_lb.frontend_nlb.dns_name
    zone_id                = data.aws_lb.frontend_nlb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app_CNAME" {
  zone_id = data.aws_route53_zone.circleci.zone_id
  name    = "app.${var.server_fqdn}"
  type    = "CNAME"
  ttl     = var.r53_ttl
  records = [var.server_fqdn]
}

resource "aws_route53_record" "nomad_CNAME" {
  zone_id = data.aws_route53_zone.circleci.zone_id
  name    = "nomad.${var.server_fqdn}"
  type    = "CNAME"
  ttl     = var.r53_ttl
  records = [data.kubernetes_service.nomad_nlb.status.0.load_balancer.0.ingress.0.hostname]
}

resource "aws_route53_record" "op_CNAME" {
  zone_id = data.aws_route53_zone.circleci.zone_id
  name    = "op.${var.server_fqdn}"
  type    = "CNAME"
  ttl     = var.r53_ttl
  records = [data.kubernetes_service.output_processor_nlb.status.0.load_balancer.0.ingress.0.hostname]
}

resource "aws_route53_record" "vms_CNAME" {
  zone_id = data.aws_route53_zone.circleci.zone_id
  name    = "vms.${var.server_fqdn}"
  type    = "CNAME"
  ttl     = var.r53_ttl
  records = [data.kubernetes_service.vms_nlb.status.0.load_balancer.0.ingress.0.hostname]
}