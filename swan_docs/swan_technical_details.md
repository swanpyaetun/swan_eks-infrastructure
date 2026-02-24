# Technical Details

## 1. AWS resources for Terraform and GitHub Actions

### 1.1. S3 bucket for Terraform remote state

S3 bucket is used as backend storage for Terraform remote state.

Bucket Versioning is enabled for state recovery in the case of accidental deletions and human error.

S3 bucket is secured by implementing the following practices:
1. Block all public access
2. Enable Bucket Versioning
3. Enable SSE-S3 (Default encryption)

### 1.2. IAM Role for GitHub Actions to authenticate to AWS

GitHub OIDC provider is added in IAM. 

IAM Role is configured to trust GitHub OIDC provider, swanpyaetun organization, and swan_eks-infrastructure repository. IAM Role is created with AdministratorAccess. 

GitHub Actions can now assume IAM Role. 

GitHub Actions authentication to AWS is secured by implementing the following practices:
1. Not storing long-lived IAM user credentials in GitHub
2. Using short-lived OIDC tokens with automatic expiration

## 2. GitHub Actions

### 2.1. swan_terraform.yml

```yaml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  workflow_dispatch:
```
"Provision AWS Infrastructure using Terraform" pipeline can be triggered in 3 ways:<br>
The CI/CD pipeline runs when a pull request is opened against the main branch.<br>
The CI/CD pipeline runs when a direct push is made to the main branch.<br>
Go to swanpyaetun/swan_eks-infrastructure repository -> Actions -> Provision AWS Infrastructure using Terraform -> Run workflow. Click "Run workflow" to run the CI/CD pipeline.

swan_terraform_plan job does the following steps: