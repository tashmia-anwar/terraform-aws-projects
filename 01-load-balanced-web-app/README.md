# Load Balanced Web App

## What This Does
Creates a production-ready web application infrastructure across 2 availability zones in AWS.

## Infrastructure Includes
- VPC with 2 public subnets
- Internet gateway
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

**VPC Networking & Multi-AZ Architecture**
- Deployed infrastructure across 2 availability zones for high availability
- If one AZ fails, the load balancer automatically routes traffic to a healthy instance in the other AZ

**Load Balancer Configuration**
- Created a target group to define backend server pools
- Configured health checks to monitor instance health
- Attached instances to the target group for automatic traffic distribution

**Security Group Design**
- ALB security group allows port 80 from the internet
- Instance security group allows port 8080 only from the load balancer
- This prevents users from bypassing the load balancer and accessing instances directly

**Terraform Resource Dependencies**
- Resources reference each other (e.g. subnets need VPC ID, instances need subnet and security group IDs)
- Understanding the order Terraform creates and destroys resources
- Using resource attributes to connect infrastructure components