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

# Create AWS organization
resource "aws_organizations_organization" "org" {
    feature_set = "ALL"
    enabled_policy_types = [
        "SERVICE_CONTROL_POLICY"
    ]
}

# Create Organiational Units (OUs)

resource "aws_organizations_organizational_unit" "dev" {
    name = "Development"
    parent_id = aws_organizations_organization.org.roots[0].id 
}

resource "aws_organizations_organizational_unit" "qa" {
    name = "QA"
    parent_id = aws_organizations_organization.org.roots[0].id 
}

resource "aws_organizations_organizational_unit" "nonprod" {
    name = "Non-Production"
    parent_id = aws_organizations_organization.org.roots[0].id 
}

resource "aws_organizations_organizational_unit" "prod" {
    name = "Production"
    parent_id = aws_organizations_organization.org.roots[0].id 
}

## SCP policy to restrict regional access

# ============================================
# SCP 1: Regional Restrictions
# ============================================
resource "aws_organizations_policy" "restrict_regions" {
    name = "RestrictRegions"
    description = "Restrict operations to US regions only, exempt admin"
    type = "SERVICE_CONTROL_POLICY"
    
    content = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "RestrictRegionalAccess"
                Effect = "Deny"
                Action = "*"
                Resource = "*"
                Condition = {
                    StringNotEquals = {
                        "aws:RequestedRegion" = [
                            "us-east-1",
                            "us-east-2",
                            "us-west-1",
                            "us-west-2"
                        ]
                    }
                    ArnNotLike = {
                        "aws:PrincipalArn" = "arn:aws:iam::*:user/tashmia.anwar" # admin user
                    }
                }
            }
        ]
    })
}

# ============================================
# SCP 2: Deny Specific Services
# ============================================
resource "aws_organizations_policy" "deny_services" {
    name = "DeniedServices"
    description = "Deny access to specific AWS services"
    type = "SERVICE_CONTROL_POLICY"
    
    content = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Sid = "DeniedServices"
            Effect = "Deny"
            Action = [
                "support:*" # deny support case creation - must go through admin
            ]
            Resource = "*"
            Condition = {
                    ArnNotLike = {
                        "aws:PrincipalArn" = "arn:aws:iam::*:user/tashmia.anwar" # admin user
                    }
                }
        }
        ]
  })
}


# ============================================
# Attach both SCPs to all the OUs
# ============================================

# Dev OU
resource "aws_organizations_policy_attachment" "dev_regions" {
  policy_id = aws_organizations_policy.restrict_regions.id
  target_id = aws_organizations_organizational_unit.dev.id
}

resource "aws_organizations_policy_attachment" "dev_deny_services" {
  policy_id = aws_organizations_policy.deny_services.id
  target_id = aws_organizations_organizational_unit.dev.id
}

# QA OU
resource "aws_organizations_policy_attachment" "qa_regions" {
  policy_id = aws_organizations_policy.restrict_regions.id
  target_id = aws_organizations_organizational_unit.qa.id
}

resource "aws_organizations_policy_attachment" "qa_deny_services" {
  policy_id = aws_organizations_policy.deny_services.id
  target_id = aws_organizations_organizational_unit.qa.id
}

# Non-Prod OU
resource "aws_organizations_policy_attachment" "nonprod_regions" {
  policy_id = aws_organizations_policy.restrict_regions.id
  target_id = aws_organizations_organizational_unit.nonprod.id
}

resource "aws_organizations_policy_attachment" "nonprod_deny_services" {
  policy_id = aws_organizations_policy.deny_services.id
  target_id = aws_organizations_organizational_unit.nonprod.id
}

# Prod OU
resource "aws_organizations_policy_attachment" "prod_regions" {
  policy_id = aws_organizations_policy.restrict_regions.id
  target_id = aws_organizations_organizational_unit.prod.id
}

resource "aws_organizations_policy_attachment" "prod_deny_services" {
  policy_id = aws_organizations_policy.deny_services.id
  target_id = aws_organizations_organizational_unit.prod.id
}