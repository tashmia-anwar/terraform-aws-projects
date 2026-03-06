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

# Basic VPC configuration

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    tags = {
        env = "test"
    }
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"

    tags = {
        env = "test"
    }
}