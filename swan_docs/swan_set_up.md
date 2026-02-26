# Instructions to set up the project

## Table of Contents

- [1. AWS](#1-aws)
  - [1.1. Create S3 bucket for Terraform remote state](#11-create-s3-bucket-for-terraform-remote-state)
  - [1.2. Create IAM Role for GitHub Actions to authenticate to AWS](#12-create-iam-role-for-github-actions-to-authenticate-to-aws)
- [2. GitHub Actions](#2-github-actions)
  - [2.1. Create repository secret](#21-create-repository-secret)
  - [2.2. Set environment variable](#22-set-environment-variable)
- [3. Terraform](#3-terraform)
  - [3.1. Configure Terraform remote state](#31-configure-terraform-remote-state)
  - [3.2. Configure Terraform provider](#32-configure-terraform-provider)
  - [3.3. Set Terraform variable values](#33-set-terraform-variable-values)
- [4. GitHub Actions CI/CD pipelines](#4-github-actions-cicd-pipelines)
  - [4.1. Run "Provision AWS Infrastructure using Terraform" pipeline](#41-run-provision-aws-infrastructure-using-terraform-pipeline)
  - [4.2. Run "Terraform Destroy" pipeline](#42-run-terraform-destroy-pipeline)

## 1. AWS

### 1.1. Create S3 bucket for Terraform remote state

In AWS Management Console, create a S3 bucket in ap-southeast-1 region with the following configurations:<br>
General configuration:<br>
&nbsp;&nbsp;&nbsp;&nbsp;Bucket type: General purpose<br>
&nbsp;&nbsp;&nbsp;&nbsp;Bucket name: swan-production-terraform-backend<br>
Object Ownership:<br>
&nbsp;&nbsp;&nbsp;&nbsp;Object Ownership: ACLs disabled (recommended)<br>
Block Public Access settings for this bucket:<br>
&nbsp;&nbsp;&nbsp;&nbsp;Block all public access<br>
Bucket Versioning:<br>
&nbsp;&nbsp;&nbsp;&nbsp;Bucket Versioning: Enable<br>
Tags:<br>
&nbsp;&nbsp;&nbsp;&nbsp;Project: swan_eks-infrastructure<br>
&nbsp;&nbsp;&nbsp;&nbsp;Environment: Production<br>
Default encryption:<br>
&nbsp;&nbsp;&nbsp;&nbsp;Encryption type: Server-side encryption with Amazon S3 managed keys (SSE-S3)<br>
&nbsp;&nbsp;&nbsp;&nbsp;Bucket Key: Enable

To add S3 bucket policy to deny insecure http traffic, in AWS Management Console, go to "S3" -> Buckets -> General purpose buckets -> swan-production-terraform-backend -> Permissions -> Bucket policy. Click "Edit". Copy and paste the following json. Click "Save changes".
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyInsecureTransport",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::swan-production-terraform-backend",
                "arn:aws:s3:::swan-production-terraform-backend/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
```

### 1.2. Create IAM Role for GitHub Actions to authenticate to AWS

In AWS Management Console, add an IAM Identity provider with the following configurations:<br>
Provider details:<br>
&nbsp;&nbsp;&nbsp;&nbsp;Provider type: OpenID Connect<br>
&nbsp;&nbsp;&nbsp;&nbsp;Provider URL: https://token.actions.githubusercontent.com<br>
&nbsp;&nbsp;&nbsp;&nbsp;Audience: sts.amazonaws.com<br>
Tags:<br>
&nbsp;&nbsp;&nbsp;&nbsp;Project: swan_eks-infrastructure<br>
&nbsp;&nbsp;&nbsp;&nbsp;Environment: Production

In AWS Management Console, create an IAM Role with the following configurations:<br>
Trusted entity type:<br>
&nbsp;&nbsp;&nbsp;&nbsp;Web identity<br>
Web identity:<br>
&nbsp;&nbsp;&nbsp;&nbsp;Identity provider: token.actions.githubusercontent.com<br>
&nbsp;&nbsp;&nbsp;&nbsp;Audience: sts.amazonaws.com<br>
&nbsp;&nbsp;&nbsp;&nbsp;GitHub organization: swanpyaetun<br>
&nbsp;&nbsp;&nbsp;&nbsp;GitHub repository: swan_eks-infrastructure<br>
Permissions policies:<br>
&nbsp;&nbsp;&nbsp;&nbsp;AdministratorAccess<br>
Role details:<br>
&nbsp;&nbsp;&nbsp;&nbsp;Role name: swan_githubactions_terraform<br>
Tags:<br>
&nbsp;&nbsp;&nbsp;&nbsp;Project: swan_eks-infrastructure<br>
&nbsp;&nbsp;&nbsp;&nbsp;Environment: Production

## 2. GitHub Actions

### 2.1. Create repository secret

In swanpyaetun/swan_eks-infrastructure repository, go to "Settings" -> Secrets and variables -> Actions.

Create a new repository secret:<br>
Name: SWAN_CI_IAM_ROLE_ARN<br>
Secret: swan_githubactions_terraform IAM Role arn from [1.2. Create IAM Role for GitHub Actions to authenticate to AWS](#12-create-iam-role-for-github-actions-to-authenticate-to-aws)

### 2.2. Set environment variable

In .github/workflows/swan_terraform.yml and .github/workflows/swan_terraform_destroy.yml, set the following environment variable:
```yaml
env:
  SWAN_AWS_REGION: "ap-southeast-1"
```

## 3. Terraform

### 3.1. Configure Terraform remote state

In swan_terraform/swan_environments/swan_production/backend.tf, set the following for "s3" backend:<br>
[bucket: "swan-production-terraform-backend"](#11-create-s3-bucket-for-terraform-remote-state)<br>
key: "swan_production/terraform.tfstate"<br>
[region: "ap-southeast-1"](#11-create-s3-bucket-for-terraform-remote-state)
```hcl
terraform {
  backend "s3" {
    bucket       = "swan-production-terraform-backend"
    key          = "swan_production/terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true # s3 state locking
    encrypt      = true
  }
}
```

### 3.2. Configure Terraform provider

In swan_terraform/swan_environments/swan_production/providers.tf, set the following for "aws" provider:
```hcl
provider "aws" {
  region = "ap-southeast-1"
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = "swan_eks-infrastructure"
      Environment = "Production"
    }
  }
}
```

### 3.3. Set Terraform variable values

In swan_terraform/swan_environments/swan_production/prod.tfvars, set the values for Terraform variables.

## 4. GitHub Actions CI/CD pipelines

### 4.1. Run "Provision AWS Infrastructure using Terraform" pipeline

"Provision AWS Infrastructure using Terraform" pipeline can be triggered in 3 ways:
1. The CI/CD pipeline runs when a pull request is opened against the main branch.
2. The CI/CD pipeline runs when a direct push is made to the main branch.
3. In swanpyaetun/swan_eks-infrastructure repository, go to "Actions" -> Provision AWS Infrastructure using Terraform. Click "Run workflow", and click "Run workflow" to run the CI/CD pipeline.

### 4.2. Run "Terraform Destroy" pipeline

In swanpyaetun/swan_eks-infrastructure repository, go to "Actions" -> Terraform Destroy. Click "Run workflow", and click "Run workflow" to run "Terraform Destroy" pipeline.