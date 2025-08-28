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
    // Lambda function names
    lambda-1-title          = "xxx-word-game-lambda-1"
    # lambda-2-title          = "bb-lambda-2-from-modular-terraform-send-data"

    api-url-routes          = "/anagram"

    s3-bucket-name          = "words-txt-test"

    // SNS title
    # sns-name                = "datetime-uuid-topic-from-modular-terraform"

    // DynamoDB field\column names
    # db-message-id-key       = "message-id"
    # db-timestamp            = "timestamp"

    // HTML web page files/folders
    # web-page-folder-path    = "./files/web-page"
    # js-file                 = "${local.web-page-folder-path}/api-config.js"
}

// Main global execute Lambda policy - to be used by all lambda functions
module "main-policy" {
    source = "./modules/policy"

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

    function-name   = module.lambda-1.function-name
    invoke-arn      = module.lambda-1.invoke-arn

    name            = "xxx-lambda-api-trigger-from-modular-terraform"       // Lambda title where the API points to for functionality

    // Routes available within the API endpoint
    routes          = [ "PUT ${local.api-url-routes}" ]
}

// ... S3 for files to be access by the Lambda

// 3. Lambda 1 : API into Anagram controller to be returned - and eventually add data into an SQS queue
module "lambda-1" {
    source                  = "./modules/lambda"

    lambda-exec-role        = module.main-policy.policy-document-json
    title                   = local.lambda-1-title                                                                  // Name of the lambda function

    description             = "xxx Retrieve data from an API and send it to an SQS : Created from modular Terraform"    // text description
    sub-folder-location     = "/lambda-1/"                                                                          // local sub-folder where the lambda function code files are located
    file-name               = "lambda_function.zip"                                                                 // zipped code files
    runtime-language        = "python3.13"                                                                          // coding language and version
    handler-file-method     = "api-handler.lambda_handler"                                                          // file dot function name

    // Environment Variables used by the function
    environment-variables   = {
            # QUEUE_URL             = "https://sqs.${var.aws-primary-region}.amazonaws.com/${var.my-aws-user-id}/${module.sqs.name}"
            S3_BUCKET_NAME          = local.s3-bucket-name
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
            resources   = ["arn:aws:s3:::${local.s3-bucket-name}"]   # S3 Bucket name
        }
        , {
            actions     = ["s3:GetObject"]
            resources   = ["arn:aws:s3:::${local.s3-bucket-name}/*"]   # S3 Bucket contents
        }
    ]
}