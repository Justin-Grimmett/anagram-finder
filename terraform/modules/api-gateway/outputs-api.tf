// Outputs data for API Gateway Module

output "api-endpoint" {
    value               = aws_apigatewayv2_api.api.api_endpoint
    description         = "The API Endpoint"
}