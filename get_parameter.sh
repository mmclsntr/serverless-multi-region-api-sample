#!/bin/bash

CMDNAME=`basename $0`
WORKDIR=`cd $(dirname $0); pwd`

SETTING_FILE=$WORKDIR/settings.conf

if [ $# -ne 3 ]; then
    echo "Usage: $CMDNAME <name> <stage> <profile>" 1>&2
    exit 1
fi

# Load config
source $SETTING_FILE

PARAM_NAME=$1
STAGE=$2
export AWS_PROFILE=$3
export AWS_DEFAULT_REGION=$PRIMARY_REGION

EXIST_PARAM_VALUE=`aws ssm get-parameter --name $PARAM_NAME --with-decryption || echo "error" `
if [ "$EXIST_PARAM_VALUE" != "error" ]; then
    echo $EXIST_PARAM_VALUE | jq -r .Parameter.Value
fi
