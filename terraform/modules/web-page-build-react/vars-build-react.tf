variable "react-path" {
    type                    = string
    description             = "The local folder path of where the React files are stored"
}

variable "do-npm-install" {
    type                    = bool
    description             = "If True the npm install command will be ran also"
    default                 = false
}
