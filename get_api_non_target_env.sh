#!/bin/bash -xe

CMDNAME=`basename $0`
WORKDIR=`cd $(dirname $0); pwd`

SETTING_FILE=$WORKDIR/settings.conf
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

REST_API_ID=`sh $GET_API_ID_SCRIPT $STAGE $AWS_PROFILE $PRIMARY_REGION`
TARGET_ENV=`aws apigatewayv2 get-api-mappings --domain-name $DOMAIN_NAME \
    --query "Items[?ApiId==\\\`$REST_API_ID\\\`]" \
    --region $PRIMARY_REGION \
    2>/dev/null \
    | jq -r .[0].Stage`

i=0
for stage in ${API_STAGES[@]}
do
    if [ "${API_STAGES[i]}" == "$TARGET_ENV" ]; then
        unset API_STAGES[i]
        API_STAGES=(${API_STAGES[@]})
        break
    fi
    let i++
done

echo ${API_STAGES[0]}
