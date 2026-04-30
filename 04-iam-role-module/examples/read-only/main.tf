module "read_only_role" {
    source = "../../modules/iam-role"

    role_name = "read-only-role"
    description = "Role with read only access to AWS"

    assume_role_policy = jsonencode(
        {
            Version = "2012-10-17"
            Statement = [{
                Effect = "Allow"
                Principal = { 
                    Service = "ec2.amazonaws.com"
                    }
                Action = "sts:AssumeRole"
                }
            ]

        }
    )

    policy_arns = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
    ]

    tags = {
        Environment = "dev"
        ManagedBy = "terraform"
    }
}