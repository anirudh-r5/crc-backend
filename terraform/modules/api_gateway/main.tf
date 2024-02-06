resource "aws_api_gateway_rest_api" "dashboard_api" {
  name        = "${var.project_name}-API"
  description = "API for the CRC Dashboard"
}

resource "aws_api_gateway_resource" "resource_stats" {
  rest_api_id = aws_api_gateway_rest_api.dashboard_api.id
  parent_id   = aws_api_gateway_rest_api.dashboard_api.root_resource_id
  path_part   = "stats"
}

resource "aws_api_gateway_method" "post_view_counter" {
  rest_api_id   = aws_api_gateway_rest_api.dashboard_api.id
  resource_id   = aws_api_gateway_resource.resource_stats.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.dashboard_api.id
  resource_id             = aws_api_gateway_resource.resource_stats.id
  http_method             = aws_api_gateway_method.post_view_counter.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.dashboard_api.id

  triggers = sha1(jsonencode([
    aws_api_gateway_resource.resource_stats,
    aws_api_gateway_method.post_view_counter,
    aws_api_gateway_integration.lambda_integration
  ]))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev_stage" {
  rest_api_id   = aws_api_gateway_rest_api.dashboard_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = "${aws_api_gateway_rest_api.dashboard_api.name}-Dev"

}

resource "aws_api_gateway_method_settings" "global_throttle" {
  rest_api_id = aws_api_gateway_rest_api.dashboard_api.id
  stage_name  = aws_api_gateway_stage.dev_stage.stage_name
  method_path = "*/*"

  settings {
    throttling_burst_limit = 50
    throttling_rate_limit  = 2
  }
}
