# Set up IAM roles for services to assume
module "scheduler_iam_role" {
    source = "../../../04-iam-role-module/modules/iam-role"
    role_name = var.scheduler_iam_role
    description = var.description
    
    assume_role_policy = jsonencode(
        {
    "Version":"2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "scheduler.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
    )

    policy_arns = var.scheduler_policy_arns
    
    tags = var.tags
}

module "lambda_iam_role" {
    source = "../../../04-iam-role-module/modules/iam-role"
    role_name = var.lambda_iam_role
    description = var.description
    
    assume_role_policy = jsonencode(
        {
    "Version":"2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
    )

    policy_arns = var.lambda_policy_arns

    tags = var.tags
}

# Lambda function
resource "aws_lambda_function" "mfa_compliance_check" {
    function_name = var.lambda_function
    role = module.lambda_iam_role.role_arn
    filename      = "lambda/handler.zip"
    runtime       = "python3.12"
    handler       = "handler.lambda_handler"

    tags = var.tags
}

# EventBridge rule
resource "aws_scheduler_schedule" "trigger" {
    name       = "lambda-trigger-no-mfa"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.cron_schedule

  target {
    arn      = aws_lambda_function.mfa_compliance_check.arn
    role_arn = module.scheduler_iam_role.role_arn
  }
}

# Allow EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_scheduler" {
  statement_id  = "AllowExecutionFromScheduler"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mfa_compliance_check.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.trigger.arn
}

# SNS topic to send alerts
resource "aws_sns_topic" "alerter" {
  name = var.sns_topic
  kms_master_key_id = "alias/aws/sns"

tags = var.tags
}

resource "aws_sns_topic_subscription" "alerter_target" {
  topic_arn = aws_sns_topic.alerter.arn
  protocol  = "email"
  endpoint  = var.email
}