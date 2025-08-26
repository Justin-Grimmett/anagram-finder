// Outputs data for S3 Bucket Module

output "id" {
    value               = aws_s3_bucket.s3.id
    description         = "The Idenitifier string of the S3 Bucket"
}

output "region" {
    value               = aws_s3_bucket.s3.region
    description         = "The Region where the S3 Bucket is located"
}

output "multiple-files" {
    value               = aws_s3_object.multiple-files
    description         = "The multiple files contained with the S3 Bucket - outputted for reference"
}