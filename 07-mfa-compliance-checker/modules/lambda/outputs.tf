# IAM roles
output "scheduler_iam_role" {
  description = "Name of the EventBridge Scheduler IAM role"
  value = module.scheduler_iam_role.role_name
}

output "scheduler_iam_role_arn" {
  description = "ARN of the EventBridge Scheduler IAM role"
  value = module.scheduler_iam_role.role_arn
}

output "lambda_iam_role" {
  description = "Name of the Lambda function IAM role"
  value = module.lambda_iam_role.role_name
}

output "lambda_iam_role_arn" {
  description = "ARN of the Lambda function IAM role"
  value = module.lambda_iam_role.role_arn
}

# Lambda function
output "lambda_function" {
  description = "Name of the Lambda function"
  value = aws_lambda_function.mfa_compliance_check.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value = aws_lambda_function.mfa_compliance_check.arn
}

# SNS topic
output "sns_topic" {
  description = "Name of the SNS topic"
  value = aws_sns_topic.alerter.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value = aws_sns_topic.alerter.arn
}