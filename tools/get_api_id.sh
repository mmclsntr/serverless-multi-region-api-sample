#!/bin/bash

CMDNAME=`basename $0`
WORKDIR=`cd $(dirname $0); pwd`
ROOTDIR=$WORKDIR/..

SETTING_FILE=$ROOTDIR/settings.conf
API_DIR=$ROOTDIR/api/

if [ $# -ne 3 ]; then
    echo "Usage: $CMDNAME <stage> <profile> <region>" 1>&2
    exit 1
fi

export STAGE=$1
export AWS_PROFILE=$2

export AWS_DEFAULT_REGION=$3

pushd $API_DIR > /dev/null
REST_API_ID=`sls info -v --stage $STAGE --region $AWS_DEFAULT_REGION | grep "ApiGatewayRestApi:" | sed -e "s/ApiGatewayRestApi: //g"`
popd > /dev/null

echo $REST_API_ID
