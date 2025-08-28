variable "react-path" {
    type                    = string
    description             = "The local folder path of where the React files are stpred"
}

variable "do-npm-install" {
    type                    = bool
    description             = "If True the npm install command will be ran also"
    default                 = false
}