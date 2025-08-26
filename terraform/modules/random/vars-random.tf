// Input Variables for Randomisation Module

variable "force-change-when-different" {
    type                    = string
    description             = "Pass in a string value which if different will force the randomisation to reset"
    default                 = ""
}