#!/bin/bash

CMDNAME=`basename $0`
WORKDIR=`cd $(dirname $0); pwd`

SETTING_FILE=$WORKDIR/settings.conf

if [ $# -ne 2 ]; then
    echo "Usage: $CMDNAME <stage> <profile>" 1>&2
    exit 1
fi

# Load config
source $SETTING_FILE

STAGE=$1
export AWS_PROFILE=$2
export AWS_DEFAULT_REGION=$PRIMARY_REGION

BUCKET_NAME=${TF_STATE_STORAGE_S3_BUCKET}${STAGE}
TABLE_NAME=${TF_STATE_LOCKING_DYNAMODB}${STAGE}

echo
echo "STAGE: $STAGE"
echo "REGION: $AWS_DEFAULT_REGION"
echo "PROFILE: $AWS_PROFILE"
echo
echo "STATE_STORAGE: $BUCKET_NAME"
echo "STATE_LOCKING: $TABLE_NAME"
echo

printf "Do you create S3 bucket and DynamoDB table [Y/n]"
read answer
if [ "$answer" != "Y" ]; then
    echo "Cancel"
    exit 2
fi

echo

# Bucket
echo "Create S3 bucket: $BUCKET_NAME"
aws s3 mb s3://$BUCKET_NAME
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
echo "Done"
echo

# DynamoDB Table
echo "Create DynamoDB table: $TABLE_NAME"
aws dynamodb create-table --table-name $TABLE_NAME \
    --attribute-definitions '[{"AttributeName":"LockID","AttributeType": "S"}]' \
    --key-schema '[{"AttributeName":"LockID","KeyType": "HASH"}]' \
    --provisioned-throughput '{"ReadCapacityUnits": 1,"WriteCapacityUnits": 1}'
echo "Done"
