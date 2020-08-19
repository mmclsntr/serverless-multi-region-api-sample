import json
import os


def hello(event, context):
    stage_name = os.environ.get("API_STAGE")
    region = os.environ.get("REGION")
    body = {
        "message": "Stage: {}, Region: {}".format(stage_name, region),
        "input": event
    }

    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }

    return response
