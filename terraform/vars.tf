// The main/master variables

// Possible types
# string    - text
# number    - numeric
# bool      - boolean
# list      - array
# set       - unordered list with no duplicates - guarantees uniqueness - a list does not
# map       - dictionary

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

variable "my-email" {
    type        = string
    description = "PRIVATE : My Email Address"
    sensitive   = true
}

variable "file-types" {
    type        = map
    description = "Possible file extentions / file types - Eg MIME Type"

    default     = {
                    bmp         = "image/bmp"
                    csv         = "text/csv"
                    gif         = "image/gif"
                    htm         = "text/html"
                    html        = "text/html"
                    css         = "text/css"
                    ico         = "image/x-icon"
                    js          = "application/javascript"
                    json        = "application/json"
                    jpg         = "image/jpeg"
                    jpeg        = "image/jpeg"
                    map         = "application/json"
                    md          = "text/markdown"
                    png         = "image/png"
                    pdf         = "application/pdf"
                    txt         = "text/plain"
                }
}