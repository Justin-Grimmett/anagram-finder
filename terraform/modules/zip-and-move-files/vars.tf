variable "folder-path" {
    type                = string
    description         = "The local folder path of where the files to be zipped are located - Note must all be in a single folder with no sub folders."
}

variable "zipped-file-name" {
    type                = string
    description         = "The output file name of the Zip file. Note do not include the dot Zip portion here - Also note this will be placed in the same folder as above (before being moved)."
    default             = "lambda_function"
}

variable "copy-folder-path" {
    type                = string
    description         = "Where the output Zipped file will be copied to. note the intention is for this to be different than the above."
}
