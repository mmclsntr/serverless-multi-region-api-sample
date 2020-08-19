module "common-primary-region" {
  /*
  Common resources in primary region
  */
  source = "./modules/regional"

  api_id          = var.api_id.primary_region
  api_stage       = var.api_stage
  api_stages      = var.api_stages
  api_name        = var.api_name
  api_key         = var.api_key
  domain_name     = var.domain_name
  acm_certificate = var.acm_certificate.primary_region

  stage  = var.stage
  region = var.regions.primary_region

  providers = {
    aws = aws.primary_region
  }
}

module "common-secondary-region" {
  /*
  Common resources in secondary region
  */
  source = "./modules/regional"

  api_id          = var.api_id.secondary_region
  api_stage       = var.api_stage
  api_stages      = var.api_stages
  api_name        = var.api_name
  api_key         = var.api_key
  domain_name     = var.domain_name
  acm_certificate = var.acm_certificate.secondary_region

  stage  = var.stage
  region = var.regions.secondary_region

  providers = {
    aws = aws.secondary_region
  }
}

module "global" {
  /*
  Resources in global
  */
  source = "./modules/global"

  domain_name = var.domain_name
  apigateway_target_domain_name = {
    primary_region   = module.common-primary-region.apigateway_target_domain_name
    secondary_region = module.common-secondary-region.apigateway_target_domain_name
  }
  apigateway_hosted_zone_id = {
    primary_region   = module.common-primary-region.apigateway_hosted_zone_id
    secondary_region = module.common-secondary-region.apigateway_hosted_zone_id
  }

  api_fqdn = {
    primary_region   = "${var.api_id.primary_region}.execute-api.${var.regions.primary_region}.amazonaws.com"
    secondary_region = "${var.api_id.secondary_region}.execute-api.${var.regions.secondary_region}.amazonaws.com"
  }

  healthcheck_path = "/${var.api_stage}/healthcheck"

  zone_id = var.zone_id

  stage   = var.stage
  regions = var.regions

  providers = {
    aws = aws.primary_region
  }
}

output "apigateway_api_key_name_primary" {
  value = module.common-primary-region.apigateway_api_key_name
}

output "apigateway_api_key_name_secondary" {
  value = module.common-secondary-region.apigateway_api_key_name
}

output "s3_bucket_bucket_name_primary" {
  value = module.common-primary-region.s3_bucket_bucket_name
}

output "s3_bucket_bucket_name_secondary" {
  value = module.common-secondary-region.s3_bucket_bucket_name
}

output "dynamodb_table_name_table-a" {
  value = module.global.dynamodb_table_name_table-a
}

output "dynamodb_table_name_table-b" {
  value = module.global.dynamodb_table_name_table-b
}
