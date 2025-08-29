resource "null_resource" "build-react" {
    provisioner "local-exec" {
        command = "cd ${var.react-path} ${var.do-npm-install==true ? "&& npm install" : ""} && npm run build"
    }
    // Force re-run on every apply
    triggers = {
        always_run = "${timestamp()}"
    }
}
