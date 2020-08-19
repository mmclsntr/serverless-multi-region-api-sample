#!/bin/bash

CMDNAME=`basename $0`
WORKDIR=`cd $(dirname $0); pwd`
ROOTDIR=$WORKDIR/..

SETTING_FILE=$ROOTDIR/settings.conf
GET_API_ID_SCRIPT=$WORKDIR/get_api_id.sh
GET_PARAM_SCRIPT=$WORKDIR/get_parameter.sh

if [ $# -ne 2 ]; then
    echo "Usage: $CMDNAME <stage> <profile>" 1>&2
    exit 1
fi

export STAGE=$1
export AWS_PROFILE=$2

# Load config
source $SETTING_FILE

PARAM_PATH=/${APP_NAME}/${STAGE}/
DOMAIN_NAME_PARAM="${PARAM_PATH}domain_name"

DOMAIN_NAME=`sh $GET_PARAM_SCRIPT $DOMAIN_NAME_PARAM $STAGE $AWS_PROFILE`
echo "Domain name: $DOMAIN_NAME"
echo "API Stages: ${API_STAGES[@]}"

echo

for region in $PRIMARY_REGION $SECONDARY_REGION
do
    echo "------"
    echo "Region: $region"
    REST_API_ID=`sh $GET_API_ID_SCRIPT $STAGE $AWS_PROFILE $region`

    echo "API ID: $REST_API_ID"
    echo

    echo "[Deployed API stages]"
    aws apigateway get-stages --rest-api-id $REST_API_ID --region $region | jq -r .item[].stageName

    echo "[Target Env]"
    TARGET_ENV=`aws apigatewayv2 get-api-mappings --domain-name $DOMAIN_NAME \
        --query "Items[?ApiId==\\\`$REST_API_ID\\\`]" \
        --region $region \
        | jq -r .[0].Stage`
    echo $TARGET_ENV

    echo "[Latest Env]"
    LATEST_ENV=`aws apigateway get-rest-api --rest-api-id $REST_API_ID --region $region \
        | jq -r .tags.latestStage`
    echo $LATEST_ENV
done
