// Input Variables for Routes of an API Gateway Sub-Module

variable "api-id" {
    type            = string
    description     = "The ID of the API to reference this Route"
}

variable "lambda-integration-id" {
    type            = string
    description     = "The ID of the Integration with the lambda function of the API which references this Route"
}

variable "route-key" {
    type            = string
    description     = "The main Key of this Route"
}