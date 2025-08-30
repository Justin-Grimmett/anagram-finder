// Input Variables for S3 Bucket Module

variable "title" {
    type                = string
    description         = "The unique Title of the S3 Bucket"
}

variable "source-files-folder-path" {
    type                = string
    description         = "The local folder path (not individual file) where the files to be uploaded to the S3 Bucket are located"
}

variable "destination-folder-path" {
    type                = string
    description         = "The destination folder path (not individual file) in the D3 where the files will go to - include slashes here - leave blank for no sub-folders at all"
    default             = ""
}

variable "file-types" {
    type                = map
    description         = "Possible file extentions / file types -- Eg 'MIME Type'"
    default             = {
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

variable "make-public-boolean" {
    type                = bool
    description         = "Only make the S3 Bucket have Public Access if this is set as True"
    default             = false
  
}