provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = var.project_name
    }
  }
}

data "archive_file" "lambda_zip" {
  type             = "zip"
  source_file      = "${path.module}/../dist/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/../dist/lambda.zip"
}

resource "aws_dynamodb_table" "metadata_table" {
  name           = "${var.project_name}Metadata"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "metaId"

  attribute {
    name = "metaId"
    type = "S"
  }
}

resource "aws_cloudwatch_log_group" "backend_logs" {
  name = "/aws/lambda/${var.project_name}Logs"
}

data "aws_iam_policy_document" "lambda_exec_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "${var.project_name}LambdaExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec_policy.json
}

resource "aws_lambda_function" "lambda_deploy" {
  filename      = "${path.module}/../dist/lambda.zip"
  function_name = "${var.project_name}Lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "nodejs20.x"
}

data "aws_iam_policy_document" "ddb_cloudwatch_policy" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable"
    ]

    resources = [aws_dynamodb_table.metadata_table.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [aws_cloudwatch_log_group.backend_logs.arn]
  }
}

resource "aws_iam_policy" "lambda_access_policy" {
  name   = "${var.project_name}LambdaServiceAccessPolicy"
  policy = data.aws_iam_policy_document.ddb_cloudwatch_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_access_attachment" {
  policy_arn = aws_iam_policy.lambda_access_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}
