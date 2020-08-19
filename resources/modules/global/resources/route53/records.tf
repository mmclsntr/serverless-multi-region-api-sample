resource "aws_route53_record" "alias-record-primary" {
  name    = var.domain_name
  type    = "A"
  zone_id = var.zone_id

  health_check_id = aws_route53_health_check.healthcheck["primary_region"].id

  alias {
    name                   = var.apigateway_target_domain_name.primary_region
    zone_id                = var.apigateway_hosted_zone_id.primary_region
    evaluate_target_health = false
  }

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = var.regions.primary_region
}

resource "aws_route53_record" "alias-record-secondary" {
  name    = var.domain_name
  type    = "A"
  zone_id = var.zone_id

  health_check_id = aws_route53_health_check.healthcheck["secondary_region"].id

  alias {
    name                   = var.apigateway_target_domain_name.secondary_region
    zone_id                = var.apigateway_hosted_zone_id.secondary_region
    evaluate_target_health = false
  }

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = var.regions.secondary_region
}
