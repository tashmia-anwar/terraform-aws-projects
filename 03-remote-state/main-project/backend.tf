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

  backend "s3" {
    bucket       = "tash-terraform-state-2025"
    key          = "project01/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}