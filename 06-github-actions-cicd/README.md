# GitHub Actions CI/CD

## What This Does
A GitHub Actions workflow that automatically validates and plans Terraform code on every push or pull request to main — no manual Terraform commands needed.

## Pipeline Steps
- `terraform fmt -check` — validates code formatting
- `terraform validate` — checks for syntax errors
- `terraform plan` — previews infrastructure changes

## Infrastructure
- S3 bucket (used as a simple Terraform target for the pipeline to run against)

## How It Works
1. Push code to main or open a pull request
2. GitHub spins up an Ubuntu VM
3. Pipeline runs fmt, validate, and plan automatically
4. AWS credentials are injected securely via GitHub Secrets

## What I Learned

**GitHub Actions**
- Workflow files live in `.github/workflows/` at the repo root
- Pipeline triggers on both push and pull_request to main
- AWS credentials are stored as GitHub Secrets and injected as environment variables at runtime - never hardcoded in code

**CI/CD Concepts**
- In real-world applications, plan runs on every PR so reviewers can see exactly what will change before approving
- Apply only runs after merge to main — that's the safety gate
- This pattern replaces running Terraform commands manually on every change