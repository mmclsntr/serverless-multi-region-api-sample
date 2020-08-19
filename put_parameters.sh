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

PARAM_PATH=/${APP_NAME}/${STAGE}/

echo
echo "STAGE: $STAGE"
echo "REGION: $AWS_DEFAULT_REGION"
echo "PROFILE: $AWS_PROFILE"
echo
echo "Prefix: $PARAM_PATH"
echo

for p in "${PARAMETERS[@]}"
do
    PARAM_NAME=$PARAM_PATH$p
    echo "$PARAM_NAME"

    EXIST_PARAM_VALUE=`aws ssm get-parameter --name $PARAM_NAME --with-decryption 2>/dev/null || echo "error" `
    if [ "$EXIST_PARAM_VALUE" == "error" ]; then
        echo "New parameter"
    else
        echo "Already exists"
        printf "Value: "
        echo $EXIST_PARAM_VALUE | jq -r .Parameter.Value

        printf "Do you override this parameter? [Y/n]"
        read answer
        if [ "$answer" == "Y" ]; then
            echo "New value"
        else
            echo "Canceled"
            echo
            continue
        fi
    fi

    printf "Enter value: "
    read PARAM_VALUE
    echo

    # confirm
    echo "Parameter name: $PARAM_NAME"
    echo "Parameter value: $PARAM_VALUE"
    printf "Update parameter [Y/n]"
    read answer
    if [ "$answer" != "Y" ]; then
        echo "Cancel"
        exit 2
    fi

    # パラメータストアへ格納
    aws ssm put-parameter \
        --cli-input-json "{\"Name\": \"$PARAM_NAME\", \"Value\": \"$PARAM_VALUE\", \"Type\": \"SecureString\"}" \
        --overwrite \
        && echo "success"
    echo
done

echo
echo "Done"

