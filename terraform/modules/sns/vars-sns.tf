// Input Variables for SNS Module

variable "name" {
    type            = string
    description     = "The Name of this SNS"
}

variable "delivery-policy" {
    type            = string
    description     = "The EOF string JSON of the Delivery Policy for this SNS"
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

variable "subscription-email" {
    type            = string
    description     = "The Email Address to be used for the Subscription for this SNS"
}