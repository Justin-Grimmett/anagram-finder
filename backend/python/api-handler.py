import json
from datetime import datetime
import uuid
import os
import boto3

#set env variables
# QUEUE_URL = os.environ['QUEUE_URL']

def lambda_handler(event, context):   
    apiEvent = event['rawPath']
    sqs = boto3.resource('sqs')
    # queue = sqs.Queue(QUEUE_URL)

    try:
        body = {}
        complete = False
        if apiEvent == "/anagram":
            print(event)
            if event['body'] != None:
                body = json.loads(event['body'])
                print(body)
                if body != {}:
                    complete = True

                # Call the main functionality here

        return json.dumps({"status" : 200 , "body" : body, "success" : complete})

    except Exception as e:
        print(e)