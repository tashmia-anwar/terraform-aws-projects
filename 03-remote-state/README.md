# Remote State Backend

## What This Does
Provisions an S3 bucket to store Terraform state remotely and prevent concurrent state modifications in team environments using S3 native state locking (no DynamoDB required).

## Infrastructure Includes
- S3 bucket with versioning enabled
- S3 native state locking

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

**Remote Backend**
- Remote state prevents drift and enables collaboration across multiple developers
- Versioning allows rollback to previous state files if needed
- S3 native locking replaces the previous DynamoDB-based approach
- Critical pattern for any production Terraform setup