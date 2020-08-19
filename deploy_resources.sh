#!/bin/bash

set -e

CMDNAME=`basename $0`
WORKDIR=`cd $(dirname $0); pwd`

SETTING_FILE=$WORKDIR/settings.conf
RESOURCE_DIR=$WORKDIR/resources/
GET_API_NON_TARGET_ENV_SCRIPT=$WORKDIR/get_api_non_target_env.sh
GET_API_ID_SCRIPT=$WORKDIR/get_api_id.sh

if [ $# -ne 4 -a $# -ne 5 ]; then
    echo "Usage: $CMDNAME <mode(plan/apply/destroy)> <target(init/all)> <stage> <profile> [<api_env>]" 1>&2
    exit 1
fi

MODE=$1
if [ "$MODE" != "plan" -a "$MODE" != "apply" -a "$MODE" != "destroy" ]; then
    echo "<mode> should be 'plan' or 'apply'"
    exit 1
fi

TARGET=$2
if [ "$TARGET" != "init" -a "$TARGET" != "all" ]; then
    echo "<target> should be 'init' or 'all'"
    exit 1
fi

# Load config
source $SETTING_FILE

export STAGE=$3
export AWS_PROFILE=$4

API_ENV=$5

export APP_NAME=$APP_NAME

echo
echo "Stage: $STAGE"
echo "Primary region: $PRIMARY_REGION"
echo "Secondary region: $SECONDARY_REGION"
echo "Profile: $AWS_PROFILE"
echo
echo "Mode: $MODE"
echo "Target: $TARGET"
echo "API Stage: $API_ENV"
echo
echo "----------------------"


if [ "$API_ENV" == "" ]; then
    # API_ENVの自動取得
    # ターゲットとなっていない方
    echo "Getting target env..."
    API_ENV=`sh $GET_API_NON_TARGET_ENV_SCRIPT $STAGE $AWS_PROFILE`
fi

# API_ENVの存在チェック
exists=false
for i in ${API_STAGES[@]}; do
    if [ "${API_STAGES[i]}" == "$API_ENV" ]; then
        exists=true
        break
    fi
done
if [ ! $exists ]; then
    echo "<api_env> should be selected from [ ${API_STAGES[@]} ]"
    exit 1
fi

# API IDの取得
echo "Getting API ID..."
REST_API_ID_PRIMARY=`sh $GET_API_ID_SCRIPT $STAGE $AWS_PROFILE $PRIMARY_REGION`
REST_API_ID_SECONDARY=`sh $GET_API_ID_SCRIPT $STAGE $AWS_PROFILE $SECONDARY_REGION`

echo
echo "Target env: $API_ENV"
echo "API ID (Primary): $REST_API_ID_PRIMARY"
echo "API ID (Secondary): $REST_API_ID_SECONDARY"
echo

printf "Deploy resources [Y/n]"
read answer
if [ "$answer" != "Y" ]; then
    echo "Cancel"
    exit 2
fi

# TFファイルの設定
TFVARS_STAGE_FILE=${RESOURCE_DIR}terraform.${STAGE}.tfvars.json
TFBACKEND_STAGE_FILE=${RESOURCE_DIR}terraform.${STAGE}.tfbackend

pushd $RESOURCE_DIR

# TF ターゲット (初期デプロイ時にデプロイするターゲットを個別で設定)
TF_TARGETS=""
if [ "$TARGET" == "init" ]; then
    echo "Deploy targets to initialize"
    for t in "${TF_INITIAL_TARGETS[@]}"
    do
        echo $t
        TF_TARGETS="$TF_TARGETS --target=$t"
    done
fi

# TFVARS (個別設定する変数) の設定
TF_VARS="-var='api_id={\"primary_region\": \"$REST_API_ID_PRIMARY\", \
    \"secondary_region\": \"$REST_API_ID_SECONDARY\"}' \
    -var='api_stage=$API_ENV'
    "

# Terraform
echo "============================"
echo "=== terraform ==="
echo "============================"
echo "= fmt ="
terraform fmt
echo "============================"
echo "= validate ="
terraform validate
echo "============================"
echo "= init ="
terraform init -reconfigure -backend-config=$TFBACKEND_STAGE_FILE
echo "============================"
echo "= workspace ="
terraform workspace new ${STAGE} || echo "Select ${STAGE}" && terraform workspace select ${STAGE}
terraform workspace show
echo "============================"
echo "= $MODE ="
DEPLOY_CMD="terraform $MODE -var-file=\"$TFVARS_STAGE_FILE\" $TF_VARS $TF_TARGETS"
echo $DEPLOY_CMD
eval $DEPLOY_CMD
echo "============================"

popd
