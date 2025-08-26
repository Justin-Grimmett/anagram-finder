// Routes for an API Gateway : sub-module

resource "aws_apigatewayv2_route" "route" {
    api_id    = var.api-id
    route_key = var.route-key

    target    = "integrations/${var.lambda-integration-id}"
}