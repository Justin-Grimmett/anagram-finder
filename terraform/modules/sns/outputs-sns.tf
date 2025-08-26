// Outputs data for SNS Module

output "name" {
    value               = aws_sns_topic.sns.name
    description         = "The Name of the SNS"
}

output "arn" {
    value               = aws_sns_topic.sns.arn
    description         = "The ARN of the SNS"
}