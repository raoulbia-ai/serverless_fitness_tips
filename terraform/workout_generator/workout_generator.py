import os
import openai
import boto3
import json
from datetime import datetime


# Retrieve secrets from AWS Secrets Manager
def get_secret(secret_name):
    client = boto3.client(service_name='secretsmanager')
    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except Exception as e:
        raise e
    else:
        secret = json.loads(get_secret_value_response['SecretString'])
        return secret


def generate_workout(level):
    prompt = f"Provide a {level} workout routine with a warmup, HIIT workout, core exercises, and flexibility exercises using bodyweight and dumbbells."
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.6
    )
    return response.choices[0].message.content


# Generate and store the workout in DynamoDB
def store_workout(date, level, workout, table):
    item = {
        'date': date,
        'level': level,
        'workout': workout
    }
    table.put_item(Item=item)


def lambda_handler(event, context):
    # Retrieve environment
    environment = os.getenv("ENVIRONMENT")

    # Set up DynamoDB
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(environment)

    # Dynamically build the secret_name based on the environment
    secret_name = f"{environment}_secret"
    secrets = get_secret(secret_name)

    # Set OpenAI credentials from secrets
    openai.organization = secrets['openai_org']
    openai.api_key = secrets['openai_key']

    levels = ["Beginner", "Intermediate", "Advanced"]

    # Generate, print, and store workouts
    for level in levels:
        generated_workout = generate_workout(level.lower())
        print(f"{level} Workout:")
        print(generated_workout)
        print()
        current_date_string = datetime.now().strftime('%Y-%m-%d')
        store_workout(current_date_string, level.lower(), generated_workout, table)

    # Return a message or result
    return {
        'statusCode': 200,
        'body': 'Workouts generated and stored successfully'
    }
