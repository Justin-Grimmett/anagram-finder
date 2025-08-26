// Role Permissions Policies

data "aws_iam_policy_document" "policy" {
    // A policy can have multiple statements  (or none)
    dynamic "statement" {
        // Loop through each statement data
        for_each = var.policy-data-statements

            // The actual data contents
            content {
                effect    = statement.value.effect
                actions   = statement.value.actions
                // Resources is optional
                resources = statement.value.resources != null && length(statement.value.resources) > 0 ? statement.value.resources : null

                // A statement can have multiple principals (or none)
                dynamic "principals" {
                    // Loop through each principal data - which can be optional
                    for_each = statement.value.principals != null ? statement.value.principals : []
                        
                        // The actual data contents
                        content {
                            type        = principals.value.type
                            identifiers = principals.value.identifiers
                        }
                }

            }
    }
}