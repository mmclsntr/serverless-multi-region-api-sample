#!/usr/bin/env bash

CMDNAME=`basename $0`
WORKDIR=`cd $(dirname $0); pwd`
ROOTDIR=$WORKDIR/..

SETTING_FILE=$ROOTDIR/settings.conf
GET_PARAM_SCRIPT=$WORKDIR/get_parameter.sh

if [ $# -ne 2 ]; then
    echo "Usage: $CMDNAME <stage> <profile>" 1>&2
    exit 1
fi

# Load config
source $SETTING_FILE

STAGE=$1
export AWS_PROFILE=$2
export AWS_DEFAULT_REGION=$PRIMARY_REGION

PARAM_PATH=/${APP_NAME}/${STAGE}/

echo
echo "STAGE: $STAGE"
echo "REGION: $AWS_DEFAULT_REGION"
echo "PROFILE: $AWS_PROFILE"
echo
echo "Prefix: $PARAM_PATH"
echo

echo $PARAM_PATH

for p in "${PARAMETERS[@]}"
do
    PARAM_NAME=$PARAM_PATH$p
    echo "Name: $PARAM_NAME"
    echo "Getting..."
    PARAM_VALUE=`sh $GET_PARAM_SCRIPT $PARAM_NAME $STAGE $AWS_PROFILE`
    echo "Value: $PARAM_VALUE"
    echo
done
