// DynamoDB NoSQL database

// Table for the DynamoDB
resource "aws_dynamodb_table" "db-table" {
    name            = var.table-name                    // Title of the Table
    hash_key        = var.table-hash-key-field          // Eg the PK of each entry
    range_key       = var.table-range-key-field         // Eg the Sort Key 

    // Hardcoded for now
    billing_mode    = "PAY_PER_REQUEST"
    

    // Required Attributes if used above - eg the Hash key and Range key
    // Although these are optional otherwise, and are also completely dynamic in terms of the amount used
    dynamic "attribute" {
        for_each = var.attributes

            content {
                name = attribute.value.name
                type = attribute.value.type
            }
    }
}