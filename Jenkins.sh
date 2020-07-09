[10:13 PM] Sairam Sunkaranam (CIS)
    
#/bin/bash


set -xe


GIT_PATH=
TERRAFORM_PATH=${GIT_PATH}


export ENV=${env}
export OS=${operating_system}
export PARAMETER_FILE=${TERRAFORM_PATH}/stack.tf
export USER_FILE=${TERRAFORM_PATH}/user-data.sh
export VARIABLE_FILE=${TERRAFORM_PATH}/variables.tf
export AWS_DEFAULT-REGION=us-east-1
export Terraform_Action=${Terraform_Action}
export Stack_Name=${Stack_Name}


if [$ENV == 'qa']; then
    export QA_BUCKET=cof-d4d-c3-qa-useast1
    export C3_PREFIX=c3-qa/c3-terraform
else 
    export QA_BUCKET=cof-d4d-c3-qa-useast1
    export C3_PREFIX=c3-qa/c3-terraform
fi


export DEPLOYMENT_ENVIRONMENT=${env}


echo Terraform_Action: ${Terraform_Action}
echo Working space: $WORKSPACE


echo "* System cleanup and Environemtn Setup *"
echo "existing files in working directory"


ls -lar
rm -r*
rm -rf .terraform
source ~/.bashrc
terraform --version


cd $WORKSPACE


wget $PARAMETER_FILE -0 ${Stack_Name}.tf
wget $USER_FILE -0 user-data.sh
wget $VARIABLE_FILE -0 variable.tf


echo "Path : " $(pwd)
echo "List of Files :" $(ls)


export ROLE_ARN="${AWS_ROLE_ARN}"


echo "* Terraform Init *"
terraform init -get=true -input=false -force-copy -backend=true \
    -backend-config="role_arn=${ROLE_ARN}" \
    -backend-config="bucket=${QA_BUCKET}" \
    -backend-config="region=us-east-1" \
    -backend-config="encryption=true" \
    -backend-config="key=${C3_PREFIX}/${Stack_Name}.tfstate" \


if [ "${Terraform_Action}" == "plan" ]; then
    echo "* TERRAFORM PLAN"
    
    terraform plan -ver "ROLE_ARN=${ROLE_ARN}" -var "Stack_Name=${Stack_Name}" -var "ec2_role=${EC2_Role}" -var "env=${env}"
    
    if [ $? == 1 ]; then
        echo "Terraform Run Failed"
    else
        echo "Terraform Run Successful"
    fi
    
    aws s3 cp ${Stack_Name}.out s3://${QA_BUCKET}/${C3_PREFIX}/ -sse --region $AWS_DEFAULT_REGION


    echo "* TERRAFORM PLAN COMPLETE *"
fi


if [ "${Terraform_Action}" == "apply" ]; then
    echo "* TERRAFORM APPLY *"
    
    terraform plan -ver "ROLE_ARN=${ROLE_ARN}" -var "Stack_Name=${Stack_Name}" -var "ec2_role=${EC2_Role}" -var "env=${env}"
    if [ $? == 1 ]; then
        echo "Terraform Plan Failed"
        exit 1
    else
        echo "Terraform Plan created Successfully"
    fi
    
    aws s3 cp ${Stack_Name}.out s3://${QA_BUCKET}/${C3_PREFIX}/ -sse --region $AWS_DEFAULT_REGION
    
    terraform apply ${Stack_Name}.out
    if [ $? == 1 ]; then
        echo "Terraform Run Failed"
    else
        echo "Terraform Run Successful"
    fi
    
    echo -e "List all the files create after apply \n" "$(ls -l)"
    
    echo "* Terraform apply complete *"
fi


if [ "${Terraform_Action}" == "destory" ]; then
    echo "* TERRAFORM DESTORY *"
    
    terraform destory -force -ver "ROLE_ARN=${ROLE_ARN}" -var "Stack_Name=${Stack_Name}" -var "ec2_role=${EC2_Role}" -var "env=${env}"
    if [ $? == 1 ]; then
        echo "Terraform Run Failed"
    else
        echo "Terraform Run Successful"
    fi
    
    echo "* Terraform Destory complete *"
    
fi    

