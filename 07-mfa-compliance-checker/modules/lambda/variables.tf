variable "scheduler_iam_role" {
  description = "IAM role name for EventBridge Scheduler to assume"
  type = string
}

variable "lambda_iam_role" {
  description = "IAM role name for Lambda function to assume"
  type = string
}

variable "scheduler_policy_arns" {
  description = "Policies to attach to EventBridge Scheduler IAM role"
  type        = list(string)
}

variable "lambda_policy_arns" {
  description = "Policies to attach to Lambda IAM role"
  type        = list(string)
}

variable "description" {
  description = "Description of the IAM role"
  type        = string
  default = ""
}

variable "cron_schedule" {
  description = "Schedule name for Lambda function trigger"
  type = string
}

variable "lambda_function" {
    description = "Name of Lambda function"
    type = string
}

variable "sns_topic" {
    description = "Name of SNS topic"
    type = string
}

variable "email" {
  description = "Email address to subscribe to SNS alerts"
  type = string
}

variable "tags" {
  description = "Tags to apply"
  type = map(string)
  default = {}
}