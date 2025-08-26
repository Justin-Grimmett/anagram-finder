// SQS Queue : Simple Queue Service

resource "aws_sqs_queue" "sqs" {
    name                        = var.name

    // Hardcoded for now
    delay_seconds               = 5         # 5 seconds - default of 0
    max_message_size            = 262144    # is the default 256KB
    message_retention_seconds   = 86400     # 1 day in seconds - default is 4 days (345600)
    receive_wait_time_seconds   = 10        # Time for which a ReceiveMessage call will wait for a message to arrive - 10 seconds - default is 0
    visibility_timeout_seconds  = 600       # 600 seconds- default is 30
}

// SQS to Lambda mapping : "Lambda Trigger"
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
    event_source_arn            = aws_sqs_queue.sqs.arn
    function_name               = var.trigger-lambda-arn
}