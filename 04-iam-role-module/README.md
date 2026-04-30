# IAM Role Module

## What This Does
A reusable Terraform module that creates IAM roles with configurable trust policies and policy attachments.

## Module Structure
```04-iam-role-module/
modules/
    iam-role/ # reusable module
examples/
    read-only/ # EC2 service role with ReadOnlyAccess
    cross-account/ # role assumable by another AWS account
```

## Inputs
| Variable | Type | Required | Description |
|---|---|---|---|
| role_name | string | yes | Name of the IAM role |
| assume_role_policy | string | yes | Trust policy JSON |
| description | string | no | Description of the role |
| policy_arns | list(string) | no | List of policy ARNs to attach |
| tags | map(string) | no | Tags to apply to the role |

## Outputs
| Output | Description |
|---|---|
| role_name | Name of the created IAM role |
| role_arn | ARN of the created IAM role |

## To Deploy
```bash
cd examples/read-only  # or cross-account
terraform init
terraform plan
terraform apply
```

## To Clean Up
```bash
terraform destroy
```

## What I Learned

**Modules**
- Variables make the same module deployable for different use cases without duplicating code
- 'for_each' with 'toset()' dynamically attaches any number of policies to a role