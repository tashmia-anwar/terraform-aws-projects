# Load Balanced Web App

## What This Does
Creates a production-ready web application infrastructure across 2 availability zones in AWS.

## Infrastructure Includes
- VPC with 2 public subnets
- Application Load Balancer
- 2 EC2 instances
- S3 bucket with encryption
- Security groups and routing

## To Deploy
```bash
terraform init
terraform plan
terraform apply
```

Visit the load balancer DNS (shown in outputs) to see the application.

## To Clean Up
```bash
terraform destroy
```

## What I Learned
- VPC networking and multi-AZ architecture
- Load balancer configuration
- Security group design
- Infrastructure dependencies in Terraform