import boto3
import json
import os
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
lambda_client = boto3.client('lambda')


def get_workout_for_today(level, table):
    # Define the key to search for in DynamoDB
    current_date_string = datetime.now().strftime('%Y-%m-%d')
    key = {'date': current_date_string, 'level': level.lower()}

    # Query DynamoDB
    response = table.get_item(Key=key)

    # Check if the item exists
    if 'Item' in response:
        return response['Item']['workout'], 200
    else:
        return None, 201


def lambda_handler(event, context):
    # Get the workout level from the event (API Gateway)
    level = event['queryStringParameters']['level']

    # Specify the DynamoDB table
    environment = os.getenv("ENVIRONMENT")
    table = dynamodb.Table(environment)

    # Name backend lambda
    backend_lambda = os.getenv("BACKEND_LAMBDA")

    # Get workout for today
    workout, status_code = get_workout_for_today(level, table)

    # CORS headers
    cors_headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "OPTIONS,GET"
    }

    # If status_code is 201, trigger the backend Lambda to generate workouts
    if status_code == 201:
        lambda_client.invoke(
            FunctionName=backend_lambda,
            InvocationType='Event'
        )
        return {
            'statusCode': 201,
            'headers': cors_headers,
            'body': 'Workouts not generated. Triggering generation.'
        }

    # If status_code is 200, return the workout
    return {
        'statusCode': 200,
        'headers': cors_headers,
        'body': json.dumps({'workout': workout})
    }
