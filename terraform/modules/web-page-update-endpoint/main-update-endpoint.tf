// The primary purpose of this is to update the location of the API endpoint to be used in the HTML web page

// To ensure the JS file is updated - eg always delete the current version of the JS file first
resource "null_resource" "delete_js" {
    // Run this script
    provisioner "local-exec" {
        command = "rm -f ${var.js-file-path}"
    }
    // This would force this to always run
    triggers = {
        always_run = timestamp()
    }
}

// Retrieve the API Gateway URL as data
data "template_file" "api_js" {
    template    = file(var.template-file-path)
    vars        = {
        api-endpoint = var.api-endpoint
    }
    // Only run once the JS file is deleted
    depends_on  = [ null_resource.delete_js ]
}

// Save into the JS file to be referenced by the HTML page
resource "null_resource" "write_js" {
    // Run this script
    provisioner "local-exec" {
        command = "echo '${data.template_file.api_js.rendered}' > ${var.js-file-path}"
    }
    // Trigger once the above template file is rendered with the updated API
    triggers = {
        api_endpoint = data.template_file.api_js.rendered
    }
}