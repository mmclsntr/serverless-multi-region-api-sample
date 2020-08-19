#!/bin/bash

CMDNAME=`basename $0`
WORKDIR=`cd $(dirname $0); pwd`

SETTING_FILE=$WORKDIR/settings.conf
RESOURCE_DIR=$WORKDIR/resources/

if [ $# -ne 3 ]; then
    echo "Usage: $CMDNAME <stage> <profile> <region>" 1>&2
    exit 1
fi

export STAGE=$1
export AWS_PROFILE=$2

export AWS_DEFAULT_REGION=$3

REST_API_ID=`sls info -v --stage $STAGE --region $AWS_DEFAULT_REGION | grep "ApiGatewayRestApi:" | sed -e "s/ApiGatewayRestApi: //g"`

echo $REST_API_ID
