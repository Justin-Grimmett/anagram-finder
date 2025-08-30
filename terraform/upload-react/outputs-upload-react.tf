// Concatenate and Output the URL of the relevant HTML file - as this is what drives the whole process
output "html-file-output" {
    description = "URL of the React HTML file(s) in the relevant S3 bucket"

    // Loop through the potential multiple foles and only return if is a HTML file
    value       = [
                    for obj in module.s3-react.multiple-files :
                        "https://${module.s3-react.id}.s3.${module.s3-react.region}.amazonaws.com/${obj.key}" 
                            if obj.key != null && endswith(lower(obj.key),  ".html")
                ]
}