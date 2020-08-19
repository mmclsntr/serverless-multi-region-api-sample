output "apigateway_target_domain_name" {
  value = aws_apigatewayv2_domain_name.domain_name.domain_name_configuration[0].target_domain_name
}

output "apigateway_hosted_zone_id" {
  value = aws_apigatewayv2_domain_name.domain_name.domain_name_configuration[0].hosted_zone_id
}
