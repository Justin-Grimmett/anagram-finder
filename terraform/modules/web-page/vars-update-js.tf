// Input Variables for the web-page / JS updating Module

variable "js-file-path" {
    type                = string
    description         = "The full file path of the dynamic JS file to be updated"
}

variable "template-file-path" {
    type                = string
    description         = "The full file path of the Template file to be used to updat the JS file dynamically"
}

variable "api-endpoint" {
    type                = string
    description         = "The API End Point string which is what will be dymanically updated within the JS file"
}