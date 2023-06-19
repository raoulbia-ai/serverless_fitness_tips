# Serverless Daily Workout Generator
This repository contains a project that dynamically generates daily workout routines with the help of OpenAI. The architecture is built using a React.js frontend, AWS API Gateway and Lambda functions for the application layer, another set of Lambda functions for the backend processing, and Amazon DynamoDB for the data layer. Infrastructure is provisioned and managed using Terraform.
## Table of Contents
[Introduction](#introduction)

[What is being built](#what-is-being-built)

[Prerequisites](#prerequisites)

[Explaining the Happy Path](#explaining-the-happy-path)

[Steps](#steps)
 - [Step 1: Clone the repository](#step-1-clone-the-repository)
 - [Step 2: First Run Terraform](#step-2-first-run-terraform)
 - [Step 3: Deploy API](#step-3-deploy-api)
 - [Step 4: Build React.js App](#step-4-build-reactjs-app)
 - [Step 5: Second Run Terraform](#step-5-second-run-terraform)

[Test the Application](#test-the-application)

[Troubleshoot](#troubleshoot)

[Conclusion](#conclusion)
## Introduction
This application aims to provide users with a daily workout routine. Users can access a React.js based front-end hosted in S3 and Cloudfront to interact with the application. The app then communicates with an AWS backend through API Gateway. Lambda functions are used to process and fetch the data. The workout plans are generated with the help of OpenAI and are stored and retrieved from a DynamoDB table.
## What is being built
The architecture is composed of several components:
* **React.js Frontend:** The user interface is built using React.js. It's a single-page application where users can view and interact with their daily workout routines.
* **AWS API Gateway:** This serves as the entry point for the backend services. It routes the incoming HTTP requests from the frontend to the appropriate Lambda functions.
* **Application Layer Lambda Function:** This is the first Lambda function that processes requests coming from the frontend through API Gateway. Its primary role is to check Amazon DynamoDB for existing workouts and to trigger the workout generation if necessary.
* **Backend Lambda Function (Workout Generator):** This function gets triggered if there is no workout routine for the current day in DynamoDB. It interacts with OpenAI to create a new workout and stores it in DynamoDB.
* **Amazon DynamoDB:** This is the database where the workout routines are stored. Each entry has an associated date and contains the workout details.

This architecture is designed to be scalable, reliable, and cost-effective.
## Prerequisites
Before you proceed, make sure you have the following prerequisites in place:

1. Git installed on your system
2. Node.js and npm installed for building the React app
3. An AWS account with the necessary permissions to create resources
4. AWS CLI configured with access credentials
5. Terraform installed
## Explaining the Happy Path
Here is the typical flow or the 'Happy Path' that a request takes through the application:
1. Request Initiation: A user accesses the React.js application in their web browser and initiates a request to view their workout for the day.
2. API Gateway: The request from the frontend hits AWS API Gateway, which acts as a managed API endpoint. The API Gateway is responsible for routing the request to the appropriate Lambda function, in this case, the application layer Lambda function.
3. Application Layer Lambda Function: The Lambda function receives the request and queries the Amazon DynamoDB table to check if there is an entry with a workout routine for today’s date.
   * If a workout for today's date is found in DynamoDB, the Lambda function retrieves it and returns the workout details to the frontend through API Gateway.
   * If no entry for today’s date is found, the Lambda function triggers another Lambda function responsible for generating the workout.
4. Workout Generator Lambda Function: This Lambda function interacts with OpenAI to create a workout routine. After generating the workout, it writes the details, including the date, to the DynamoDB table.
5. Response to Frontend: The application layer Lambda function queries the DynamoDB table again to retrieve the newly created workout (if it was necessary to create one). It then sends the workout details back through the API Gateway to the React.js frontend.
6. Displaying Workout on Frontend: The React.js application receives the workout details and displays them to the user.

This flow ensures that the user is always presented with a workout for the current day, and if one does not exist, it gets generated dynamically.
## Steps
### Step 1: Clone the repository
Start by cloning the repository to your local machine. Run the following command in your terminal:
```bash
git clone https://github.com/semperfitodd/serverless_fitness_tips.git
```
### Step 2: First Run Terraform
Update **Owner** tag in versions.tf

Update **local.domain** in locals.tf

Navigate to the Terraform directory:
```bash
cd serverless_fitness_tips/terraform
```
Initialize Terraform:
```bash
terraform init
```
Save a plan with Terraform:
```bash
terraform plan -out=plan.out
```
Apply the Terraform configuration to create the AWS resources:
```bash
terraform apply plan.out
```
Please note that this step might take some time as it is provisioning resources in your AWS account.
### Step 3: Deploy API
1. Login to the AWS Console
2. Navigate to API Gateway
3. Select *serverless_fitness_tips*
4. Click Deploy api to prod
![deploy_api.png](files%2Fdeploy_api.png)
5. Take note of the **Invoke URL**
![invoke_url.jpg](files%2Finvoke_url.jpg)
### Step 4: Build React.js App
Navigate to the React app directory and install the necessary dependencies:
```bash
cd files
npx create-react-app workoutgenerator
```
Update the App.js placeholder **API_INVOKE_URL** with the actual URL
```bash
cp *.js workoutgenerator/src
```
Build the React app:
```bash
cd workoutgenerator
npm run build
```
### Step 5: Second Run Terraform
This is to upload the files to the S3 bucket
```bash
cd ../..
```
Save a plan with Terraform:
```bash
terraform plan -out=plan.out
```
Apply the Terraform configuration to create the AWS resources:
```bash
terraform apply plan.out
```
## Test the Application
After the Terraform apply is successful, you can now access the React.js app.

https://fitness.<YOUR_DOMAIN>
![website.png](files%2Fwebsite.png)
## Troubleshoot
Run the React app locally. From the serverless_fitness_tips/terraform/files/workoutgenerator
```bash
npm start
```
403 error in browser
S3 DNS propagation causes issues if created outside of us-east-1. Usually resolves itself in about 2 hours.
## Conclusion
You have successfully deployed and tested a daily workout generator app with a React.js frontend and an AWS backend, orchestrated using Terraform. If you encounter any issues, please check your configurations and ensure all prerequisites are met.