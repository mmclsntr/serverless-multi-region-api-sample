resource "aws_route53_health_check" "healthcheck" {
  for_each = var.api_fqdn

  fqdn              = each.value
  type              = "HTTPS"
  port = 443
  resource_path     = var.healthcheck_path
  failure_threshold = "3"
  request_interval  = "10"
}
