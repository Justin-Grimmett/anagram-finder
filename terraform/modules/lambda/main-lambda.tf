// Lambda functions

// The execute role
resource "aws_iam_role" "lambda-exec-role" {
    name               = "${var.title}-role"
    assume_role_policy = var.lambda-exec-role
}

// The Role Permissions Policy document
module "lambda-policy-doc" {
    source = "../policy"

    policy-data-statements = var.policy-data-statements
}

// The main data for the Lambda function
resource "aws_lambda_function" "lambda" {
    function_name    = var.title                                                                    // The name of the function
    description      = var.description                                                              // The text description of the function
    filename         = "${var.parent-folder-location}/${var.sub-folder-location}/${var.file-name}"  # Where the local files are located locally - Ensure your code is zipped and path is correct
    handler          = var.handler-file-method                                                      // Where the code to be ran first is located - File name dot function name
    runtime          = var.runtime-language                                                         // The programming code language and version
    
    role             = aws_iam_role.lambda-exec-role.arn                                            // Set the execute role

    // Pass in Environment Variables
    environment {
        variables = var.environment-variables
    }

    // The Policy Document must be created first
    depends_on = [ module.lambda-policy-doc ]

    // hardcoded for now *********************
    memory_size      = var.memory-size
    timeout          = 600
    architectures    = ["x86_64"]
    ephemeral_storage {
        size = 512
    }
    snap_start {
        # Enable SnapStart for faster cold starts
        apply_on = "None"
    }

}

// Attach the Policy Document to the Policy
resource "aws_iam_policy" "lambda-policy" {
    name                            = "${var.title}-policy"
    policy                          = module.lambda-policy-doc.policy-document-json
}

// Attach the Policy to the Execute Role for this Lambda
resource "aws_iam_role_policy_attachment" "lambda-policy-attach" {
    role                            = aws_iam_role.lambda-exec-role.name
    policy_arn                      = aws_iam_policy.lambda-policy.arn
}

// Event Invoke Config
resource "aws_lambda_function_event_invoke_config" "lambda-invoke-config" {
    function_name                   = aws_lambda_function.lambda.function_name
    maximum_event_age_in_seconds    = var.event-max-age
    maximum_retry_attempts          = var.event-max-retries
}

// Recursion Config
resource "aws_lambda_function_recursion_config" "lambda-recursive-loop" {
    function_name                   = aws_lambda_function.lambda.function_name
    recursive_loop                  = var.recursive-loop-type
}

// Runtime Management Config
resource "aws_lambda_runtime_management_config" "lambda-runtime-management-config" {
    function_name                   = aws_lambda_function.lambda.function_name
    update_runtime_on               = var.update-runtime-on-type
}

// CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda-log-group" {
    name                            = "${var.log-location}${var.title}"
}

// CloudWatch Log Stream
resource "aws_cloudwatch_log_stream" "lamba-log-stream" {
    name                            = "${var.title}-log-stream"
    log_group_name                  = aws_cloudwatch_log_group.lambda-log-group.name
}