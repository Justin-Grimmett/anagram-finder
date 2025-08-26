// Input Variables for API Gateway Module
variable "function-name" {
    type            = string
    description     = "The name of the lambda function relevant for this API"
}

variable "invoke-arn" {
    type           = string
    description     = "The ARN of the lambda function relevant for this API"
}

variable "name" {
    type            = string
    description     = "The main name of this API Gateway"
}

variable "routes" {
    type            = set(string)
    description     = "A string list of the potetially multiple routes to be used by this API Gateway"
    default         = []
}