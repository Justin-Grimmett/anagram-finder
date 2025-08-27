import json
from datetime import datetime
import uuid
import os
import boto3
import anagram

#set env variables
ANAGRAM_URL_ROUTE = os.environ['ANAGRAM_URL_ROUTE']

def lambda_handler(event, context):  
    wordData = {"success" : False}
    try: 
        apiEvent = event['rawPath']
        sqs = boto3.resource('sqs')
        # queue = sqs.Queue(QUEUE_URL)

        body = {}
        successful = False
        if apiEvent == ANAGRAM_URL_ROUTE:       # API Route
            if event['body'] != None:
                body = json.loads(event['body'])
                if body != {}:
                    if body["letters"] != None:
                        # The main anagram word finding functionality
                        wordData = anagram.main(body["letters"], True)
                        if wordData["success"] == True:
                            successful = True

        return json.dumps({"status" : 200 , "body" : body, "success" : successful, "error" : None, "wordData" : wordData})

    except Exception as e:
        print(e)
        return json.dumps({"status" : 500 , "body" : body, "success" : False, "error": e, "wordData" : wordData}) 