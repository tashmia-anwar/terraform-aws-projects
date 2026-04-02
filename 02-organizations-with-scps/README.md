# Organizations with Service Control Policies (SCPs)

## What This Does
Creates a production-ready AWS Organization with multiple organizational units and Service Control Policies for governance and compliance.

## Infrastructure Includes
- AWS Organization (your account becomes the management account)
- 4 organizational units (Dev, QA, Non-Production, Production)
- 2 Service Control Policies applied across all OUs

## To Deploy
```bash
terraform init
terraform plan
terraform apply
```

## To Clean Up
```bash
terraform destroy
```

## What I Learned

**Organizations Architecture**
- Enabled Organizations on the account, making it the management account
- Created 4 practical organizational units (Dev, QA, Non-Production, Production) as containers for accounts
- Used SCPs as guardrails for account permissions
- Can apply different SCPs to different OUs based on environment needs

**Service Control Policies**
- Centralize access controls at the organization level
- Regional restriction SCP: Limits operations to US regions only (us-east-1, us-east-2, us-west-1, us-west-2), with admin user exemption
- Service denial SCP: Blocks AWS Support case creation to ensure requests go through admin, with admin user exemption

**Terraform for AWS Organizations**
- Organization must be created before OUs
- SCPs can be created independently 
- Policy attachments require both the policy and target OU to exist
- Used `jsonencode()` to write IAM policies in HCL format