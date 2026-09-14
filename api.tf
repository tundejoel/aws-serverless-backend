# The front door
resource "aws_apigatewayv2_api" "backend" {
  name          = "portfolio-backend"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://adedayoafolabi.com", "https://www.adedayoafolabi.com"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

# Connect the door to the function
resource "aws_apigatewayv2_integration" "visit_counter" {
  api_id                 = aws_apigatewayv2_api.backend.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.visit_counter.invoke_arn
  payload_format_version = "2.0"
}

# Which path goes to which function
resource "aws_apigatewayv2_route" "visits" {
  api_id    = aws_apigatewayv2_api.backend.id
  route_key = "GET /visits"
  target    = "integrations/${aws_apigatewayv2_integration.visit_counter.id}"
}

# The published version of the API that the world sees
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.backend.id
  name        = "$default"
  auto_deploy = true
}

# Permission: allow this API (and only this API) to invoke the function
resource "aws_lambda_permission" "apigw_visit_counter" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visit_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.backend.execution_arn}/*/*"
}

output "api_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}