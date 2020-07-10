
#I have mentioned only the changes and the respective ine numbers 
#Metioned two different version as well. original (Actual code) and changed (The changes we have to deploy) or should be removed

## Line no - 10
#Original 
GIT_PATH="Hard coded Git path"
#changed - Point to be noted -> (We need to add one String parameter named Git_Path and one choice parameternamed Git_Branch in Jenkins Job)
export GIT_PATH=${Git_Path} 
export GIT_BRANCH=${Git_Branch}

## Line no - 11
# Remove this line, we don't require this any more
TERRAFORM_PATH=${GIT_PATH}


## Line no - 15, 16, 17 should be removed
export PARAMETER_FILE=${TERRAFORM_PATH}/stack.tf
export USER_FILE=${TERRAFORM_PATH}/user-data.sh
export VARIABLE_FILE=${TERRAFORM_PATH}/variables.tf


## Line no - [25 -31]
#Original 
if [$ENV == 'qa']; then
    export QA_BUCKET=cof-d4d-c3-qa-useast1
    export C3_PREFIX=c3-qa/c3-terraform
else 
    export QA_BUCKET=cof-d4d-c3-qa-useast1
    export C3_PREFIX=c3-qa/c3-terraform
fi
#changed - Point to be noted -> (We need to add two more choice parameters in Jenkins Job namely Bucket and Prefix)
export BUCKET=${Bucket}
export C3_PREFIX=${Prefix}

## Line no - [53 -55]
#Original 
wget $PARAMETER_FILE -0 ${Stack_Name}.tf
wget $USER_FILE -0 user-data.sh
wget $VARIABLE_FILE -0 variable.tf
#changed - Point to be noted -> (We are going to use Git commands to downalod the files instead of wget)
git clone ${GIT_PATH} -b ${GIT_BRANCH} workfolder
mv workfolder/* .
rm workfolder


## Line no - 67
#Original 
    -backend-config="bucket=${QA_BUCKET}" \
#changed 
    -backend-config="bucket=${BUCKET}" \
