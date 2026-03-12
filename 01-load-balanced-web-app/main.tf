terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create VPC

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
    environment = "dev"
    appID = "000123"
    }
}

# Create web app security group

resource "aws_security_group" "security_group" {
    name = "web-app-sg"
    vpc_id = aws_vpc.vpc.id

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
    environment = "dev"
    appID = "000123"
    }
}

# Create 2 EC2 instances for simple web app

resource "aws_instance" "instance_1" {
    ami = "ami-0f3caa1cf4417e51b" # Amazon Linux 2023 kernel-6.1 AMI
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.security_group.id]
    subnet_id = aws_subnet.subnet_1.id
    
    user_data = <<-EOF
    #!/bin/bash
    echo "Hello World 1" > index.html
    python3 -m http.server 8080 &
    EOF

    tags = {
        environment = "dev"
        appID = "000123"
    }
}

resource "aws_instance" "instance_2" {
    ami = "ami-0f3caa1cf4417e51b" # Amazon Linux 2023 kernel-6.1 AMI
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.security_group.id]
    subnet_id = aws_subnet.subnet_2.id
    
    user_data = <<-EOF
    #!/bin/bash
    echo "Hello World 2" > index.html
    python3 -m http.server 8080 &
    EOF

    tags = {
    environment = "dev"
    appID = "000123"
    }
}

# Create S3 bucket for file storage

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "bucket" {
    bucket = "simple-web-app-data-bucket-${random_id.bucket_suffix.hex}"
    force_destroy = true

    tags = {
    environment = "dev"
    appID = "000123"
    }
}

# Enable SSE for S3 bucket

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
    bucket = aws_s3_bucket.bucket.id
    
    rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# Enable S3 bucket versioning

resource "aws_s3_bucket_versioning" "versioning" {
    bucket = aws_s3_bucket.bucket.id
    
    versioning_configuration {
    status = "Enabled"
    }
}

# Create 2 subnets for AZ

resource "aws_subnet" "subnet_1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        environment = "dev"
        appID = "000123"
    }
}

resource "aws_subnet" "subnet_2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"

    tags = {
        environment = "dev"
        appID = "000123"
    }
}

# Create ALB security group

resource "aws_security_group" "alb" {
    name = "alb-security-group"
    vpc_id = aws_vpc.vpc.id
    
    tags = {
    environment = "dev"
    appID = "000123"
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Create ALB

resource "aws_alb" "alb" {
    name = "app-load-balancer"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb.id]
    subnets = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

    tags = {
    environment = "dev"
    appID = "000123"
    }
}

# Create ALB target group

resource "aws_lb_target_group" "instances" {
  name     = "my-app-load-balancer-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

# Adding both instances into load balancer target group

resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_1.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_2.id
  port             = 8080
}

# Create ALB listener and forward all traffic to target group

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}

# Create internet gateway for internet access

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    environment = "dev"
    appID = "000123"
  }
}

# Create a public route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    environment = "dev"
    appID = "000123"
  }
}

# Associate both subnets to this public route table

resource "aws_route_table_association" "subnet_1" {
  subnet_id = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_2" {
  subnet_id = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public.id
}

# Outputs

output "alb_dns_name" {
  value = aws_alb.alb.dns_name
  description = "Load balancer DNS"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.bucket.id
  description = "S3 bucket name"
}