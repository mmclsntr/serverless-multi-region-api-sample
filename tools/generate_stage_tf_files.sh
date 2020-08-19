#!/bin/bash

CMDNAME=`basename $0`
WORKDIR=`cd $(dirname $0); pwd`
ROOTDIR=$WORKDIR/..

SETTING_FILE=$ROOTDIR/settings.conf
RESOURCE_DIR=$ROOTDIR/resources/
GET_PARAM_SCRIPT=$WORKDIR/get_parameter.sh

TFVARS_TEMPLATE_FILE=${RESOURCE_DIR}terraform.stage.tfvars.template
TFBACKEND_TEMPLATE_FILE=${RESOURCE_DIR}terraform.stage.tfbackend.template

if [ $# -ne 2 ]; then
    echo "Usage: $CMDNAME <stage> <profile>" 1>&2
    exit 1
fi

# Load config
source $SETTING_FILE

export STAGE=$1
export AWS_PROFILE=$2
export AWS_DEFAULT_REGION=$PRIMARY_REGION

export APP_NAME=$APP_NAME
export PRIMARY_REGION=$PRIMARY_REGION
export SECONDARY_REGION=$SECONDARY_REGION
# 配列から、["aaa","bbb"]の形にの文字列に変換
export API_STAGE_LIST=`printf -v tmp '"%s",' ${API_STAGES[@]}; echo [${tmp%,}]`


# TFVARS
TFVARS_STAGE_FILE=${RESOURCE_DIR}terraform.${STAGE}.tfvars
echo "Create $TFVARS_STAGE_FILE"

PARAM_PATH=/${APP_NAME}/${STAGE}/

for p in "${PARAMETERS[@]}"
do
    PARAM_NAME=$PARAM_PATH$p
    PARAM_VALUE=`sh $GET_PARAM_SCRIPT $PARAM_NAME $STAGE $AWS_PROFILE`
    eval export $p=$PARAM_VALUE
done

envsubst < $TFVARS_TEMPLATE_FILE > $TFVARS_STAGE_FILE

# TFBACKEND
TFBACKEND_STAGE_FILE=${RESOURCE_DIR}terraform.${STAGE}.tfbackend
echo "Create $TFBACKEND_STAGE_FILE"

export TF_STATE_STORAGE_S3_BUCKET=$TF_STATE_STORAGE_S3_BUCKET
export TF_STATE_LOCKING_DYNAMODB=$TF_STATE_LOCKING_DYNAMODB

envsubst < $TFBACKEND_TEMPLATE_FILE > $TFBACKEND_STAGE_FILE

echo "Done"
