// Input Variables for Randomisation Module

variable "force-change-when-different" {
    type                    = string
    description             = "Pass in a string value which if different will force the randomisation to reset"
    default                 = ""
}

variable "length" {
    type                    = number
    description             = "The length of the random string"
    default                 = 16
}

variable "include-upper" {
    type                    = bool
    description             = "Include Upper case letters in the random string? Set because S3 Bucket names must be lower case"
    default                 = true
}