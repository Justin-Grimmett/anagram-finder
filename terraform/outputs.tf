// Concatenate and Output the URL of the relevant HTML file - as this is what drives the whole process
output "html-file-output" {
    description = "URL of the React HTML file(s) in the relevant S3 bucket"

    // Loop through the potential multiple foles and only return if is a HTML file
    value       = var.mode-num != 1 ? [
                    for obj in module.s3-react[0].multiple-files :
                        "https://${module.s3-react[0].id}.s3.${module.s3-react[0].region}.amazonaws.com/${obj.key}" 
                            if obj.key != null && endswith(lower(obj.key),  ".html")
                ] : null
}

output "random-string" {
    value               = var.mode-num == 1 ? local.random : null
    sensitive           = true
    description         = "The randomised Local string variable to be used by following functionality"
}