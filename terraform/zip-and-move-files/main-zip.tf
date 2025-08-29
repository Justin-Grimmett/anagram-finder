// Zip all the files in a single folder path, then move the newly created Zipped file to different folder

resource "null_resource" "zip-and-move" {
    provisioner "local-exec" {
        command = <<EOT
            cd ${var.folder-path}
            zip ${var.zipped-file-name}.zip *.*
            mv ${var.zipped-file-name}.zip ${var.copy-folder-path}
        EOT
    }
    // Force re-run on every apply
    triggers = {
        always_run = "${timestamp()}"
    }
}