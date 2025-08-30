variable "random-string-in" {
    type                = string
    description         = "A randomised string to be passed in - eg to be used by React upload mode after being created in Main mode"
}

variable "aws-primary-region" {
    type        = string
    description = "The primary AWS region"
    default     = "ap-southeast-2"  // Eg Sydney AU
}

variable "my-aws-access-key" {
    type        = string
    description = "PRIVATE : My AWS Access Key"
    sensitive   = true
}

variable "my-aws-secret-key" {
    type        = string
    description = "PRIVATE : My AWS Secret Key"
    sensitive   = true
}

variable "my-aws-user-id" {
    type        = number
    description = "PRIVATE : My AWS User ID (I think that is what it is) value"
    sensitive   = true
}