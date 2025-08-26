// Outputs data for Lambda function Module

output "function-name" {
    value           = aws_lambda_function.lambda.function_name
    description     = "The name of the lambda function"
}

output "invoke-arn" {
    value           = aws_lambda_function.lambda.invoke_arn
    description     = "The Invoke ARN of the lambda function"
}

output "arn" {
    value           = aws_lambda_function.lambda.arn
    description     = "The main ARN of the lambda function"
}