locals {
  frontend_lambda_name = "frontend"
}

data "archive_file" "frontend" {
  source_file = "${path.module}/${local.frontend_lambda_name}/${local.frontend_lambda_name}.py"
  output_path = "${path.module}/${local.frontend_lambda_name}/${local.frontend_lambda_name}.zip"
  type        = "zip"
}

data "aws_iam_policy_document" "lambda_execution_role_frontend" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "frontend_lambda_policy" {
  statement {
    actions   = ["dynamodb:*"]
    effect    = "Allow"
    resources = [module.dynamodb_table.dynamodb_table_arn]
  }
  statement {
    actions = [
      "lambda:*",
    ]
    resources = [aws_lambda_function.openai.arn]
  }
}

resource "aws_iam_policy" "frontend_lambda_policy" {
  name   = "${var.environment}_frontend_lambda_policy"
  policy = data.aws_iam_policy_document.frontend_lambda_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "frontend_lambda_policy" {
  role       = aws_iam_role.lambda_execution_role_frontend.name
  policy_arn = aws_iam_policy.frontend_lambda_policy.arn
}

resource "aws_iam_role" "lambda_execution_role_frontend" {
  name = "${var.environment}_frontend_lambda_execution_role"

  assume_role_policy = data.aws_iam_policy_document.lambda_execution_role_frontend.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "frontend_lambda_execution_policy" {
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  role       = aws_iam_role.lambda_execution_role_frontend.name
}

resource "aws_lambda_function" "frontend" {
  filename      = data.archive_file.frontend.output_path
  description   = "Check DynamoDB for workouts and return or run backend"
  function_name = "${var.environment}_${local.frontend_lambda_name}"
  role          = aws_iam_role.lambda_execution_role_frontend.arn
  handler       = "${local.frontend_lambda_name}.lambda_handler"
  runtime       = "python3.9"
  timeout       = 120

  environment {
    variables = {
      ENVIRONMENT    = module.dynamodb_table.dynamodb_table_id
      BACKEND_LAMBDA = aws_lambda_function.openai.function_name
    }
  }

  source_code_hash = data.archive_file.frontend.output_base64sha256

  tags = var.tags
}
