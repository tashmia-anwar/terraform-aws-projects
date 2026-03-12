# Load Balanced Web App

## What This Does
Creates a production-ready web application infrastructure across 2 availability zones in AWS.

## Infrastructure Includes
- VPC with 2 public subnets
- Application Load Balancer
- 2 EC2 instances
- S3 bucket with encryption
- Security groups and routing

## Traffic Flow

1. **User Request** - Internet traffic arrives at the Application Load Balancer on port 80
2. **Load Balancer** - ALB performs health checks and forwards requests to a healthy backend instance on port 8080
3. **EC2 Instances** - One of the two instances processes the request and returns the response
4. **Load Distribution** - Traffic is automatically distributed across both instances for balanced load and high availability

**Note:** The S3 bucket is included in this architecture to demonstrate a complete multi-tier application pattern, though it is not actively used by the simple web servers in this example.

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