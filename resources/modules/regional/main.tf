module "apigateway" {
  source = "./resources/apigateway"

  api_id          = var.api_id
  api_stage       = var.api_stage
  api_stages       = var.api_stages
  domain_name     = var.domain_name
  acm_certificate = var.acm_certificate

  api_name = var.api_name
  api_key = var.api_key

  stage = var.stage
}

module "s3" {
  source = "./resources/s3"

  api_name = var.api_name
  stage = var.stage
  region = var.region
}

output "apigateway_api_key_name" {
  value = module.apigateway.apigateway_api_key_name
}

output "s3_bucket_bucket_name" {
  value = module.s3.s3_bucket_bucket_name
}
