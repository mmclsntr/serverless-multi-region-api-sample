import json
import os

import boto3
from botocore.config import Config

def hello(event, context):
    api_env = os.environ.get("API_ENV")
    stage = os.environ.get("STAGE")
    region = os.environ.get("REGION")
    region_type = os.environ.get("REGION_TYPE")
    table_a = os.environ.get("TABLE_A")
    table_b = os.environ.get("TABLE_B")
    bucket_name = os.environ.get("BUCKET_NAME")

    msg = "API ENV: {}, Stage: {}, Region: {}, Region type: {}, Table: {}, {}, Bucket: {}".format(
        api_env,
        stage,
        region,
        region_type,
        table_a,
        table_b,
        bucket_name
    )

    print(msg)

    # Get objects in S3 Bucket
    s3_client = boto3.client('s3')
    response = s3_client.put_object(
            Bucket=bucket_name,
            Key='objectkey',
            Body='filetoupload',
    )
    print(response)

    # Write table
    dynamodb_client = boto3.client('dynamodb')
    response = dynamodb_client.put_item(
        Item={
            'id': {
                'S': 'test',
            },
            'attr': {
                'S': 'aaa',
            },
        },
        TableName=table_a,
    )
    print(response)

    response = dynamodb_client.put_item(
        Item={
            'id': {
                'S': 'test',
            },
            'attr': {
                'S': 'aaa',
            },
        },
        TableName=table_b,
    )
    print(response)

    body = {
        "message": msg,
        "input": event
    }

    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }

    return response


def healthcheck(event, context):
    api_env = os.environ.get("API_ENV")
    stage = os.environ.get("STAGE")
    region = os.environ.get("REGION")
    region_type = os.environ.get("REGION_TYPE")
    table_a = os.environ.get("TABLE_A")
    table_b = os.environ.get("TABLE_B")
    bucket_name = os.environ.get("BUCKET_NAME")

    retry_count = os.environ.get("AWS_API_RETRY_COUNT")

    msg = "API ENV: {}, Stage: {}, Region: {}, Region type: {}, Table: {}, {}, Bucket: {}".format(
        api_env,
        stage,
        region,
        region_type,
        table_a,
        table_b,
        bucket_name
    )

    print(msg)

    # Set max count of retries
    config = Config(retries={
        'max_attempts': retry_count
    })

    # Get objects in S3 Bucket
    s3_client = boto3.client('s3', config=config)
    response = s3_client.list_objects_v2(
        Bucket=bucket_name,
    )
    print(response)

    # Read table
    dynamodb_client = boto3.client('dynamodb', config=config)
    response = dynamodb_client.get_item(
        Key={
            'id': {
                'S': 'test',
            },
        },
        TableName=table_a,
        ConsistentRead=True
    )
    print(response)
    response = dynamodb_client.get_item(
        Key={
            'id': {
                'S': 'test',
            },
        },
        TableName=table_b,
        ConsistentRead=True
    )
    print(response)

    body = {
        "message": msg,
        "input": event
    }

    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }

    return response
