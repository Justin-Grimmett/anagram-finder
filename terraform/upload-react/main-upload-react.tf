terraform {
    
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

// AWS account access details
provider "aws" {
    // Set these as Input Variables
    // Eg : terraform apply -var "my-aws-access-key=abc" -var "my-aws-secret-key=123" -var "my-aws-user-id=321" -var "random-string-in=randomstring
    region      = var.aws-primary-region
    access_key  = var.my-aws-access-key
    secret_key  = var.my-aws-secret-key

}

module "s3-react" {
    source                      = "./../modules/s3-bucket"

    source-files-folder-path    = "./../../build"
    
    title                       = "${var.random-string-in}-react-web-page"
    make-public-boolean         = true    
}