terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# CloudWatch event rule
resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name        = "daily-lambda-trigger"
  description = "Triggers Lambda function daily to scan for access keys older than 90 days"

  schedule_expression = "cron(0 12 * * ? *)" # Runs daily at 12:00 PM UTC
}

# IAM role for Lambda to assume
module "lambda_execution_role" {
  source = "../04-iam-role-module/modules/iam-role"

  role_name   = "lambda-execution-role"
  description = "IAM role for Lambda function to assume"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    }
  )

  policy_arns = [
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess" # Need to scope this down for Prod
  ]

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }

}

# Lambda function
resource "aws_lambda_function" "lambda_function" {
  function_name = "access-keys-scanner"
  role          = module.lambda_execution_role.role_arn
  filename      = "lambda/handler.zip"
  runtime       = "python3.12"
  handler       = "handler.lambda_handler"
}

# Connect CloudWatch rule to Lambda
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.daily_trigger.name
  arn  = aws_lambda_function.lambda_function.arn
}

# Allow CloudWatch to invoke the Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}

# SNS topic to send alerts
resource "aws_sns_topic" "sns_alerter" {
  name              = "iam-access-key-rotation-alerter"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "sns_subscription" {
  topic_arn = aws_sns_topic.sns_alerter.arn
  protocol  = "email"
  endpoint  = "tashmia.anwar20@gmail.com"
}