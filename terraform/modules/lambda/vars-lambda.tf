// Input Variables for Lambda function Module

variable "title" {
    type                = string
    description         = "The text Title of the Lambda function"
}

variable "description" {
    type                = string
    description         = "The text Description of the Lambda function - eg what it is and what it does"
}

variable "parent-folder-location" {
    type                = string
    description         = "The Parent folder path location locally here of where the sub-folders for where the Lambda function files are located"
    default             = "./files/lambda/"  // Eg if from master parent Main.TF
}

variable "sub-folder-location" {
    type                = string
    description         = "The sub-folder path location locally here of where this exact Lambda function files are located"
}

variable "file-name" {
    type                = string
    description         = "The name of the exact File of this Lambda function - to be uploaded onto AWS"
}

variable "handler-file-method" {
    type                = string
    description         = "The location of the actual code inside the Lambda function which is to be run - eg File name Dot Method name"
}

variable "runtime-language" {
    type                = string
    description         = "The programing language run time of the contents of the lambda function - eg language name and verion number"
}

variable "policy-data-statements" {
    description     = "The full contents of a Statement of a Policy or Role - for a Lambda specifically"
    default         = []

    type            = list(object({
                            actions     = list(string)
                            effect      = optional(string, "Allow")
                            resources   = optional(list(string), null)
                            principals  = optional(list(object({
                                                type        = string
                                                identifiers = list(string)
                                        })))
                    }))
}

variable "lambda-exec-role" {
    type            = string
    description     = "The JSON of the main Lambda execute role"
}

variable "environment-variables" {
    description     = "Map of environment variables for the Lambda function"
    type            = map(string)
    default         = {}
}

variable "event-max-age" {
    description     = "Maximum Lambda event age, in seconds"
    type            = number
    default         = 21600
}

variable "event-max-retries" {
    description     = "Maximum Lambda number of even retries"
    type            = number
    default         = 2
}

variable "recursive-loop-type" {
    description     = "What should happen if a recursive loop occurs - string"
    type            = string
    default         = "Terminate"
}

variable "update-runtime-on-type" {
    description     = "String type for aws_lambda_function_recursion_config : update_runtime_on"
    type            = string
    default         = "Auto"
}

variable "log-location" {
    description     = "Parent location on the AWS side for where lambda logs are to be placed"
    type            = string
    default         = "/aws/lambda/"
}

variable "memory-size" {
    description     = "The MB used for the maximum mrmory size of the Lambda"
    type            = number
    default         = 128
}