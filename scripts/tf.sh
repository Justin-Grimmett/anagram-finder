# == VALIDAION =================================================================================================================================================
# 1. Argument validation check - exit if the below 5 parameters are not passed in
if [ "$#" -ne 5 ]; then
    echo "ERROR : Required parameters not passed in - Usage: $0 <1 : Type> <2 : my-aws-access-key : 20 characters> <3 : my-aws-secret-key : 40 characters> <4 : my-aws-user-id : 12 digits> <5 : my-email-address>"
    exit 1
fi

# 2. Check if any are empty
if test -z "$1"; then
    echo "The first parameter (Terraform Type is empty." >&2; exit 1 
elif test -z "$2"; then
    echo "The second parameter (my-aws-access-key) is empty." >&2; exit 1
elif test -z "$3"; then
    echo "The third parameter (my-aws-secret-key) is empty." >&2; exit 1
elif test -z "$4"; then
    echo "The fourth parameter (my-aws-user-id) is empty." >&2; exit 1
elif test -z "$5"; then
    echo "The fifth parameter (my-email-address) is empty." >&2; exit 1
fi

# 3. Must be a number
re='^[0-9]+$'
if ! [[ $4 =~ $re ]] ; then
   echo "Error: The fourth parameter (my-aws-user-id) must be a number" >&2; exit 1
fi

# Ensure is the correct directory
if [[ "${PWD##*/}" == "scripts" ]]; then
    cd ..
fi

# Actually run the relevant other Terraform bash sub-scripts from this ============================================================================================
if [[ $1 == "apply" ]]; then
    # Apply
    bash ./scripts/tf-apply.sh $2 $3 $4 $5
elif [[ $1 == "destroy" ]]; then
    # Destroy
    bash ./scripts/tf-destroy.sh $2 $3 $4 $5
else
    echo "Error: Incorrect Terraform Type passed in!" >&2; exit 1
fi