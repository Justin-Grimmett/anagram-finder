// The Input Variables for the DynamoDB Module

variable "table-name" {
    type                = string
    description         = "The Name of the DynamoDB Table"
}

variable "table-hash-key-field" {
    type                = string
    description         = "The Name of the Field to be used as the Hash Key for the Table - eg the PK of each entry"
}

variable "table-range-key-field" {
    type                = string
    description         = "The Name of the Field to be used as the Range Key for the Table - eg the Sort Key (eg the field of each entry to sort them by sequentually)"
}

variable "attributes" {
    description     = "The contents of an Attribute for the DynamoDB - can be multiple"
    default         = []

    type            = list(object({
                            name    = string
                            type    = optional(string, "S")   // "S" for String
                    }))
}

