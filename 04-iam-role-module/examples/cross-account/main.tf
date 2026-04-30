module "cross_account_role" {
  source = "../../modules/iam-role"

  role_name   = "cross-account-role"
  description = "Role that allows another AWS account to assume access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::ACCOUNT_ID:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}