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
"Provision AWS Infrastructure using Terraform" pipeline can be triggered in 3 ways:
1. The CI/CD pipeline runs when a pull request is opened against the main branch.
2. The CI/CD pipeline runs when a direct push is made to the main branch.
3. Go to swanpyaetun/swan_eks-infrastructure repository -> Actions -> Provision AWS Infrastructure using Terraform -> Run workflow. Click "Run workflow" to run the CI/CD pipeline.

swan_terraform_plan job does the following steps:
1. checkout repository
2. set up terraform in the runner
3. configure aws credentials using oidc
4. terraform init
5. check terraform format
6. check whether the configuration is valid
7. terraform plan and generate terraform plan file
8. upload terraform plan file only if the event is push or manually triggered

swan_terraform_apply job runs after swan_terraform_plan job succeeds. swan_terraform_apply job runs only if the event is push or manually triggered. swan_terraform_apply job does the following steps:
1. checkout repository
2. set up terraform in the runner
3. configure aws credentials using oidc
4. terraform init
5. download terraform plan file
6. create terraform resources using terraform plan file
Terraform plan file is used so that only reviewed resources during plan stage are applied, and no modification is done between plan and apply stage.