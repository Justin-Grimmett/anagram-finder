# Run the Terraform (destroy) scripts

# Note this is NOT to be ran Manually - but from the "tf.sh" script

# == Run the second Terraform script : Destroy B : Create S3 and Upload React web files created in the first TF file =====================================================
# Change into the relevant sub directory
cd terraform/upload-react
# Run the Terraform - note the random string contents is not relevant for the Destroy
terraform destroy -var "my-aws-access-key=$1" -var "my-aws-secret-key=$2" -var "my-aws-user-id=$3" -var "random-string-in=random_string" -auto-approve

# == Actually running the first Terraform script : Destroy A : The majority of the resources ============================================================================
# change to the main TF directory
cd ..
# Run the Destroy script
terraform destroy -var "my-aws-access-key=$1" -var "my-aws-secret-key=$2" -var "my-aws-user-id=$3" -var "my-email=$4" -auto-approve


