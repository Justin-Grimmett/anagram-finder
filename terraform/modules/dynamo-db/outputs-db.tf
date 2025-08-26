// The Outputs data for the DynamoDB Module

output "name" {
    value       = aws_dynamodb_table.db-table.name
    description = "The Name of the DynamoDB Table"
}

output "arn" {
    value           = aws_dynamodb_table.db-table.arn
    description     = "The ARN of the DynamoDB Table"
}