terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "instance_1" {
    ami = "ami-0f3caa1cf4417e51b" # Amazon Linux 2023 kernel-6.1 AMI
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instances.name]
    user_data = <<-EOF
    #!/bin/bash
    echo "Hello World 1" > index.html
    python3 -m http.server 8080 &
    EOF
}

resource "aws_instance" "instance_2" {
    ami = "ami-0f3caa1cf4417e51b" # Amazon Linux 2023 kernel-6.1 AMI
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instances.name]
    user_data = <<-EOF
    #!/bin/bash
    echo "Hello World 2" > index.html
    python3 -m http.server 8080 &
    EOF
}