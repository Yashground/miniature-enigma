#!/bin/bash

# Generate a unique S3 bucket name using a random string
BUCKET_NAME="my-unique-bucket-$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-')"
STACK_NAME="s3-cloudfront-stack-$(date +%s)"
PIPELINE_ROLE_ARN=${CODEPIPELINE_ROLE_ARN}

# Run the AWS CLI command to create the CloudFormation stack
aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://s3-cloudfront.yml \
  --parameters ParameterKey=BucketName,ParameterValue=$BUCKET_NAME \
               ParameterKey=CodePipelineRoleArn,ParameterValue=$PIPELINE_ROLE_ARN \
  --capabilities CAPABILITY_NAMED_IAM

echo "Stack creation initiated. Stack Name: $STACK_NAME, S3 Bucket Name: $BUCKET_NAME"

# Check if the stack creation was successful
while true; do
    STACK_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].StackStatus" --output text)
    if [[ $STACK_STATUS == "CREATE_COMPLETE" ]]; then
        echo "Stack creation completed successfully."
        break
    elif [[ $STACK_STATUS == "CREATE_FAILED" || $STACK_STATUS == "ROLLBACK_COMPLETE" ]]; then
        echo "Stack creation failed with status: $STACK_STATUS"
        exit 1
    else
        echo "Stack creation in progress... Current status: $STACK_STATUS"
        sleep 30
    fi
done
