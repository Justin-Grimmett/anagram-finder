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
    // Eg : terraform apply -var "my-aws-access-key=abc" -var "my-aws-secret-key=123" -var "my-aws-user-id=321" -var "my-email=aa"
    region      = var.aws-primary-region
    access_key  = var.my-aws-access-key
    secret_key  = var.my-aws-secret-key

}

// To prevent duplicate hardcoding of this data when it is to be used in multiple places
locals {
    // A randomised string
    random                  = module.random.random-string
    
    // Lambda function names
    lambda-1-title          = "${local.random}-word-game-lambda-1"
    # lambda-2-title          = "bb-lambda-2-from-modular-terraform-send-data"

    api-url-routes          = "/anagram"

    s3-lambda-1-bucket-name          = "${local.random}-words-txt-test"

    // SNS title
    # sns-name                = "datetime-uuid-topic-from-modular-terraform"

    // DynamoDB field\column names
    # db-message-id-key       = "message-id"
    # db-timestamp            = "timestamp"

    // HTML web page files/folders
    # web-page-folder-path    = "./files/web-page"
    # js-file                 = "${local.web-page-folder-path}/api-config.js"
}

// For a random string
module "random" {
    source                  = "./modules/random"
    
    include-upper           = false
    length                  = 10
}

// Main global execute Lambda policy - to be used by all lambda functions
module "main-policy" {
    source          = "./modules/policy"
    count           = var.mode-num != 2  ? 1 : 0               // Main mode - run all

    policy-data-statements = [
        {
            actions   = ["sts:AssumeRole"]
        
            principals = [{
                type        = "Service"
                identifiers = ["lambda.amazonaws.com"]
            }]
        }
    ]
}


// 2. API : to direct to Lambda 1
module "api" {
    source          = "./modules/api-gateway"
    count           = var.mode-num != 2  ? 1 : 0               // Main mode - run all

    function-name   = module.lambda-1[0].function-name
    invoke-arn      = module.lambda-1[0].invoke-arn

    name            = "${local.random}-lambda-api-trigger-from-modular-tf"       // Lambda title where the API points to for functionality

    // Routes available within the API endpoint
    routes          = [ "PUT ${local.api-url-routes}" ]
}

module "update-web-endpoint" {
    source                      = "./modules/web-page-update-endpoint"
    count                       = var.mode-num != 2  ? 1 : 0               // Main mode - run all

    api-endpoint                = module.api[0].api-endpoint
    js-file-path                = "./../src/dynamic/api-config.tsx"

    template-file-path          = "./../src/dynamic/template.tsx.tpl"      // Template file which is used to populate the contents of the JS file

    depends_on                  = [ module.api ]
}

// S3 Bucket for files to be access by the Lambda
module "s3-lambda-1-files" {
    source                      = "./modules/s3-bucket"
    count                       = var.mode-num != 2  ? 1 : 0               // Main mode - run all

    source-files-folder-path    = "./files/s3"
    file-types                  = var.file-types
    
    title                       = local.s3-lambda-1-bucket-name    
}

// Create the zipped Lambda files
module "zip-lambda-1" {
    source                  = "./modules/zip-and-move-files"
    count                   = var.mode-num != 2  ? 1 : 0               // Main mode - run all

    folder-path             = "./../backend/python"
    copy-folder-path        = "${path.cwd}/files/lambda/lambda-1/"  # dynamically include the current working folder
}

// 3. Lambda 1 : API into Anagram controller to be returned - and eventually add data into an SQS queue
module "lambda-1" {
    source                  = "./modules/lambda"
    count                   = var.mode-num != 2  ? 1 : 0               // Main mode - run all

    lambda-exec-role        = module.main-policy[0].policy-document-json    // The [0] is required because using condition count turns the resource into a tuple list
    title                   = local.lambda-1-title                                                                  // Name of the lambda function

    description             = "${local.random} Retrieve data from an API and send it to an SQS : Created from modular Terraform"    // text description
    sub-folder-location     = "/lambda-1/"                                                                          // local sub-folder where the lambda function code files are located
    file-name               = "lambda_function.zip"                                                                 // zipped code files
    runtime-language        = "python3.13"                                                                          // coding language and version
    handler-file-method     = "api-handler.lambda_handler"                                                          // file dot function name
    memory-size             = 512                                                                                   // memory size in MB - I was running out at the default 128

    depends_on              = [ module.main-policy ]

    // Environment Variables used by the function
    environment-variables   = {
            # QUEUE_URL             = "https://sqs.${var.aws-primary-region}.amazonaws.com/${var.my-aws-user-id}/${module.sqs.name}"
            S3_BUCKET_NAME          = local.s3-lambda-1-bucket-name
            ANAGRAM_URL_ROUTE       = local.api-url-routes
    }
    
    // For Role Permissions
    policy-data-statements  = [
        # {
        #     actions     = [ "sqs:SendMessage" , "sqs:createqueue" , "SNS:CreateTopic"]
        #     resources   = [ "arn:aws:sqs:${var.aws-primary-region}:${var.my-aws-user-id}:*" , "arn:aws:sns:${var.aws-primary-region}:${var.my-aws-user-id}:*" ]
        # } , 
        {
            actions     = ["logs:CreateLogGroup"]
            resources   = ["arn:aws:logs:${var.aws-primary-region}:${var.my-aws-user-id}:*"]
        } , 
        {
            actions     = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
            resources   = ["arn:aws:logs:${var.aws-primary-region}:${var.my-aws-user-id}:log-group:/aws/lambda/${local.lambda-1-title}:*"]
        }
        , {
            actions     = ["s3:ListBucket"]
            resources   = ["arn:aws:s3:::${local.s3-lambda-1-bucket-name}"]   # S3 Bucket name
        }
        , {
            actions     = ["s3:GetObject"]
            resources   = ["arn:aws:s3:::${local.s3-lambda-1-bucket-name}/*"]   # S3 Bucket contents
        }
    ]
}

// Build the React production files - to be deployed to an S3 Bucket
module "build-react" {
    source              = "./modules/web-page-build-react"
    count               = var.mode-num != 2  ? 1 : 0               // Main mode - run all

    react-path          = "./../src"     // Note this is the path relative from the current path where this Main TF file is located
}

// Commented out for now, because it won't work to dynamically build the React files and upload them (the new versions) to S3 all at once
module "s3-react" {
    source                      = "./modules/s3-bucket"
    count                       = var.mode-num != 1  ? 1 : 0               // Only create S3 and upload dynamically created React files

    source-files-folder-path    = "./../build"
    file-types                  = var.file-types
    
    title                       = "${var.random-string-in}-react-web-page"
    make-public-boolean         = true

    # depends_on                  = [ module.build-react ]    # Note modular Depends-On should be the output of the module
    
}
