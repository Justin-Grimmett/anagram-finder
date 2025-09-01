# Run the Terraform (apply) scripts

# Note this is NOT to be ran Manually - but from the "tf.sh" script

# == Actually running the first Terraform script : A : The majority of the resources ============================================================================
# change directory
cd terraform
# run TF script
terraform apply -var "my-aws-access-key=$1" -var "my-aws-secret-key=$2" -var "my-aws-user-id=$3" -var "my-email=$4" -auto-approve

# Get the output from the above Terraform script as is required for the second TF script
# Set the file name
temp_text_file=tf-outs-temp-only.txt
# Run the output
terraform output > $temp_text_file
# output variable
random_string=""
# Was the output file actually created?
if [ -e "$temp_text_file" ]; then 
    # Get the contents of the file
    content=$(cat "$temp_text_file") 
    # Strip everything before the first quote and after the second quote - and insert into the variable
    random_string=$(echo "$content" | sed -E 's/.*"(.*)".*/\1/')
    # Delete the temp file created
    rm $temp_text_file
else 
    echo "Required Terraform Output File not found: $temp_text_file"
fi

# == Run the second Terraform script : B : Create S3 and Upload React web files created in the first TF file =====================================================
# If the variable is not empty
if [ -n "$random_string" ]; then
    # Change into the relevant directory
    cd upload-react
    # Run the Terraform
    terraform apply -var "my-aws-access-key=$1" -var "my-aws-secret-key=$2" -var "my-aws-user-id=$3" -var "random-string-in=$random_string" -auto-approve
else
    echo "Error: Required Terraform output string was not generated correctly." >&2; exit 1
fi
