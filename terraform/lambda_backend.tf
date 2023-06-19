locals {
  backend_lambda_name = "workout_generator"

  venv_name = "myenv"
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "backend_lambda_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "openai_lambda_policy" {
  statement {
    actions   = ["dynamodb:Put*"]
    effect    = "Allow"
    resources = [module.dynamodb_table.dynamodb_table_arn]
  }
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:Get*",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = [aws_secretsmanager_secret.openai.arn]
  }
}

resource "aws_iam_policy" "openai_lambda_policy" {
  name   = "${var.environment}_openai_lambda_policy"
  policy = data.aws_iam_policy_document.openai_lambda_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "openai_lambda_policy" {
  role       = aws_iam_role.lambda_execution_role_backend.name
  policy_arn = aws_iam_policy.openai_lambda_policy.arn
}

resource "aws_iam_role" "lambda_execution_role_backend" {
  name = "${var.environment}_openai_lambda_execution_role"

  assume_role_policy = data.aws_iam_policy_document.backend_lambda_execution_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  role       = aws_iam_role.lambda_execution_role_backend.name
}

resource "aws_lambda_function" "openai" {
  filename      = "${path.module}/${local.backend_lambda_name}/${local.backend_lambda_name}.zip"
  description   = "Create workouts and store in DynamoDB"
  function_name = "${var.environment}_${local.backend_lambda_name}"
  role          = aws_iam_role.lambda_execution_role_backend.arn
  handler       = "${local.backend_lambda_name}.lambda_handler"
  runtime       = "python3.9"
  timeout       = 120

  environment {
    variables = {
      ENVIRONMENT = module.dynamodb_table.dynamodb_table_id
    }
  }

  source_code_hash = filebase64sha256("${path.module}/${local.backend_lambda_name}/${local.backend_lambda_name}.zip")

  tags = var.tags

  depends_on = [null_resource.package_lambda]
}

resource "null_resource" "package_lambda" {
  provisioner "local-exec" {
    command = <<-EOF
      VENV_NAME="${local.venv_name}"
      FILES_DIRECTORY="./${local.backend_lambda_name}"
      OPENAI_FILENAME="${local.backend_lambda_name}"

      # Creating a python virtual environment
      python3.9 -m venv $VENV_NAME

      # Activating the virtual environment
      source $VENV_NAME/bin/activate

      # Installing the requirements
      pip3.9 install -r $FILES_DIRECTORY/requirements.txt

      # Copying the python packages to the files directory
      cp -R $VENV_NAME/lib/python3.9/site-packages/ $FILES_DIRECTORY/

      # Going into the files directory
      cd $FILES_DIRECTORY

      # Remove old zip file
      rm -f $OPENAI_FILENAME.zip

      # Creating the zip file
      zip -r $OPENAI_FILENAME.zip .

      # Removing the files and directories after zip is created
      find . -mindepth 1 -type d -exec rm -r {} \;
      rm *.pth
      rm six.py
      deactivate

      # Removing the virtual environment directory
      cd ..
      rm -rf $VENV_NAME
    EOF
  }
  triggers = {
    requirements_hash      = filesha256("${path.module}/${local.backend_lambda_name}/requirements.txt")
    workout_generator_hash = filesha256("${path.module}/${local.backend_lambda_name}/${local.backend_lambda_name}.py")
  }
}

