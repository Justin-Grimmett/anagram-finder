// Outputs data for Policies Module

output "policy-document-json" {
    value = data.aws_iam_policy_document.policy.json
}
