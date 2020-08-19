#!/bin/bash

set -e

CMDNAME=`basename $0`
WORKDIR=`cd $(dirname $0); pwd`
TOOLDIR=$WORKDIR/tools

SETTING_FILE=$WORKDIR/settings.conf
RESOURCE_DIR=$WORKDIR/resources/
GET_API_NON_TARGET_ENV_SCRIPT=$TOOLDIR/get_api_non_target_env.sh

if [ $# -ne 3 -a $# -ne 4 ]; then
    echo "Usage: $CMDNAME <mode(deploy/remove)> <stage> <profile> [<api_env>]" 1>&2
    exit 1
fi

MODE=$1
if [ "$MODE" != "deploy" -a "$MODE" != "remove" ]; then
    echo "<mode> should be 'deploy' or 'remove'"
    exit 1
fi

echo "Mode: $MODE"

echo

# Load config
source $SETTING_FILE

export STAGE=$2
export AWS_PROFILE=$3
API_ENV=$4

TERRAFORM_TARGETS=""

if [ "$API_ENV" == "" ]; then
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
if [ "$API_ENV" == "$STAGE" ]; then
    echo "Master Alias"
elif [ ! $exists ]; then
    echo "<api_env> should be selected from [ ${API_STAGES[@]} ]"
    exit 1
fi

echo
echo "Stage: $STAGE"
echo "Primary region: $PRIMARY_REGION"
echo "Secondary region: $SECONDARY_REGION"
echo "Profile: $AWS_PROFILE"
echo
echo "Target Env: $API_ENV"
echo

printf "Deploy APIs [Y/n]"
read answer
if [ "$answer" != "Y" ]; then
    echo "Cancel"
    exit 2
fi

pushd $RESOURCE_DIR
echo ""
echo "Change workspace:  ${STAGE}"
terraform workspace select ${STAGE}
echo
echo "Get options from outputs of resources"
OPTS_LIST=`terraform output -json | jq -r '. | to_entries | map(.value = .value.value) | .[] | "--" + .key  + " \"" + .value + "\"" '`
popd

# Deploy
echo "Deploy"
for region in $PRIMARY_REGION $SECONDARY_REGION
do
    echo "---------------"
    echo $region
    DEPLOY_CMD="sls $MODE --region $region --stage $STAGE --alias $API_ENV $OPTS_LIST"
    echo $DEPLOY_CMD
    eval $DEPLOY_CMD
    echo
done


echo "Done"
