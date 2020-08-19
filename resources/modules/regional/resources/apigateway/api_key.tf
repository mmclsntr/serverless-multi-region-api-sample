resource "aws_api_gateway_api_key" "api-key" {
  name = "${var.api_name}-${var.stage}"
  value = var.api_key
}

resource "aws_api_gateway_usage_plan" "usage-plan" {
  name = "${var.api_name}-${var.stage}"

  dynamic api_stages {
    for_each = var.api_stages
    content {
      api_id = var.api_id
      stage  = api_stages.value
    }
  }
}

resource "aws_api_gateway_usage_plan_key" "usage-plan-key" {
  key_id        = aws_api_gateway_api_key.api-key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage-plan.id
}

output "apigateway_api_key_name" {
  value = aws_api_gateway_api_key.api-key.name
}
