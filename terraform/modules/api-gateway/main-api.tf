// API Gateway

# Create the HTTP API Gateway
resource "aws_apigatewayv2_api" "api" {
    name          = var.name  # Main name of the API Gateway

    // Hardcoded for now
    protocol_type = "HTTP"

    // For localhost testing
    cors_configuration {
        allow_origins   = [ "http://localhost:3000" , var.api-endpoint ]
        allow_methods   = [ "POST" , "PUT" ]
        allow_headers   = ["content-type"]
        max_age         = 300
    }
}

# Integration with the Lambda function (to be re-used across multiple routes)
resource "aws_apigatewayv2_integration" "lambda-integration" {
    api_id                    = aws_apigatewayv2_api.api.id
    integration_uri           = var.invoke-arn

    // Hardcoded for now
    integration_type          = "AWS_PROXY"
    integration_method        = "POST"
    payload_format_version    = "2.0"
    connection_type           = "INTERNET"
}

# The possible Routes for this API endpoint - from the sub-module
module "routes" {
    source                      = "./route"

    // Loop through multiple
    for_each                    = var.routes

            route-key                   = each.value

            api-id                      = aws_apigatewayv2_api.api.id
            lambda-integration-id       = aws_apigatewayv2_integration.lambda-integration.id
  
}

# Deploy the API
resource "aws_apigatewayv2_stage" "stage" {
    api_id                      = aws_apigatewayv2_api.api.id

    // hardcoded for now
    name                        = "$default"
    auto_deploy                 = true
}

# Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigw_permission" {
    function_name               = var.function-name
    source_arn                  = "${aws_apigatewayv2_api.api.execution_arn}/*/*"

    // hardcoded for now
    statement_id                = "AllowAPIGatewayInvoke"
    action                      = "lambda:InvokeFunction"
    principal                   = "apigateway.amazonaws.com"   
}