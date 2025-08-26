// S3 Bucket : Simple Storage Service

resource "aws_s3_bucket" "s3" {
    bucket      = var.title
}

// Static multiple Files to be uploaded to S3 Bucket
resource "aws_s3_object" "multiple-files" {
    // Loop through the relevant files in the folder set above
    for_each            = fileset(var.source-files-folder-path, "**")

        bucket          = aws_s3_bucket.s3.id
        key             = "${var.destination-folder-path}${each.key}"                           // The full location path on AWS S3 where the files will go to
        source          = "${var.source-files-folder-path}/${each.value}"                       // The local full file path of what files are to be uploaded
        source_hash     = each.value == "api-config.js" ? null : filemd5("${var.source-files-folder-path}/${each.value}") # Causes an error for the dynamic JS file - hardcoded for now

        // Extract file extension and look up content type, default to "application/octet-stream" if not found
        // - This is required because the HTML file was being downloaded when accessed as a URL and not opened in the browser directly
        content_type    = lookup(
                            var.file-types,
                            lower(trimspace(split(".", each.value)[length(split(".", each.value)) - 1])),
                            "application/octet-stream"
                        )
}

// Policy for Public Access - A
resource "aws_s3_bucket_ownership_controls" "oc-public-access" {
    count               = var.make-public-boolean ? 1 : 0               // This will only be ran if this boolean variable is set to True

    bucket              = aws_s3_bucket.s3.id
    
    rule {
        object_ownership = "BucketOwnerPreferred"                       // Hardcoded for now
    }
}

// .. - B
resource "aws_s3_bucket_public_access_block" "pab-public-access" {
    count                       = var.make-public-boolean ? 1 : 0       // This will only be ran if this boolean variable is set to True

    bucket                      = aws_s3_bucket.s3.id

    block_public_acls           = false
    block_public_policy         = false
    ignore_public_acls          = false
    restrict_public_buckets     = false
}

// .. - C
resource "aws_s3_bucket_acl" "public-read" {
    count                       = var.make-public-boolean ? 1 : 0       // This will only be ran if this boolean variable is set to True

    bucket                      = aws_s3_bucket.s3.id

    acl                         = "public-read"                         // Hardcoded for now

    // Only create this resource once the below exist
    depends_on  = [
        aws_s3_bucket_ownership_controls.oc-public-access,
        aws_s3_bucket_public_access_block.pab-public-access
    ]
}

// Main Policy
module "policy-statement" {
    source                      = "../policy"

    // Role Permissions - hardcoded for now
    policy-data-statements      = [
                                    {
                                        actions         = [ "s3:GetObject" ]
                                        resources       = [ "${aws_s3_bucket.s3.arn}/*" ]  # Apply the policy to all objects in the bucket
                                        principals      = [{
                                                            type            = "AWS"
                                                            identifiers     = ["*"]  # Allowing public access
                                                        }]
                                    }
                                ]
}

// Attach the policy statement to the policy
resource "aws_s3_bucket_policy" "policy" {
    bucket                      = aws_s3_bucket.s3.id
    policy                      = module.policy-statement.policy-document-json

    // Run this Resource only once the below resource is created first
    depends_on                  = [ aws_s3_bucket_public_access_block.pab-public-access ]
}