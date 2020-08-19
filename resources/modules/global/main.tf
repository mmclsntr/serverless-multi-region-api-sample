module "route53" {
  source = "./resources/route53"

  domain_name = var.domain_name
  apigateway_target_domain_name = var.apigateway_target_domain_name
  apigateway_hosted_zone_id = var.apigateway_hosted_zone_id
  zone_id          = var.zone_id
  api_fqdn = var.api_fqdn
  healthcheck_path = var.healthcheck_path
  regions = var.regions
}

module "dynamodb" {
  source = "./resources/dynamodb"

  stage = var.stage
  regions = var.regions
}

output "dynamodb_table_name_table-a" {
  value = module.dynamodb.dynamodb_table_name_table-a
}

output "dynamodb_table_name_table-b" {
  value = module.dynamodb.dynamodb_table_name_table-b
}
