// Input Variables for Policies Module

variable "policy-data-statements" {
    description     = "The full contents of a Statement of a Policy or Role"
    default         = []

    type            = list(object({
                            actions     = list(string)
                            effect      = optional(string, "Allow")             // Optional - if not provided the default will be set as "Allow"
                            resources   = optional(list(string), null)          
                            principals  = optional(list(object({                // No default set for this - eg would be blank/null if not provided
                                                type        = string
                                                identifiers = list(string)
                                        })))
                    }))
}