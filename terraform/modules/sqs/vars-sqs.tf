// Input Variables for the SQS Module

variable "name" {
    type            = string
    description     = "The Name of this SQS"
}

variable "trigger-lambda-arn" {
    type            = string
    description     = "The ARN of the Lambda function which is the Trigger for this SQS"
}