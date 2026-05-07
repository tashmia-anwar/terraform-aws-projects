# IAM Access Key Rotation Alerter

## What This Does
A Lambda function that scans all IAM users for access keys older than 90 days and sends an email alert via SNS. Triggered daily via CloudWatch Events.

## Infrastructure
- CloudWatch Events rule (daily cron schedule)
- Lambda function (Python 3.12)
- IAM execution role (via Project 04 module)
- SNS topic with KMS encryption and email subscription

## To Deploy
```bash
cd lambda
zip handler.zip handler.py
cd ..
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
- Reused Project 04's IAM role module for the Lambda execution role instead of re-writing IAM resources from scratch

**Lambda + Python**
- Wrote a Python handler using boto3 to list IAM users, calculate access key age, and trigger SNS alerts for keys older than 90 days

**SNS**
- Integrated SNS with Lambda for automated email alerting with KMS encryption at rest

**CloudWatch Events**
- Used a cron schedule to trigger Lambda daily without any manual intervention