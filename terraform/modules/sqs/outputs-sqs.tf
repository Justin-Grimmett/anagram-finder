// Outputs data for the SQS Module

output "name" {
    value       = aws_sqs_queue.sqs.name
    description = "The Name of the SQS"
}

output "arn" {
    value           = aws_sqs_queue.sqs.arn
    description     = "The ARN of the SQS"
}