// SNS : Simple Notification Service

// Set the email delivery policy
resource "aws_sns_topic" "sns" {
    name                = var.name
    delivery_policy     = var.delivery-policy
}

// SNS Role Permissions Policy document
module "sns-policy-doc" {
    source = "../policy"

    policy-data-statements = var.policy-data-statements
}

// SNS : Attach the policy doc to the policy
resource "aws_iam_policy" "sns-policy" {
    name   = "${var.name}-policy"
    policy = module.sns-policy-doc.policy-document-json
}

// SNS Email Subscription
resource "aws_sns_topic_subscription" "sns-email-target" {
    topic_arn = aws_sns_topic.sns.arn
    endpoint  = var.subscription-email

    // Hardcoded for now
    protocol  = "email"
}