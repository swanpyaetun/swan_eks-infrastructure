# Prerequisites

## Table of Contents

- [1. AWS](#1-aws)
  - [1.1. Create S3 bucket for Terraform remote state](#11-create-s3-bucket-for-terraform-remote-state)
  - [1.2. Create IAM Role for GitHub Actions to authenticate to AWS](#12-create-iam-role-for-github-actions-to-authenticate-to-aws)
  - [1.3. Route 53 domain and public hosted zone](#13-route-53-domain-and-public-hosted-zone)
- [2. Terraform](#2-terraform)
  - [2.1. Configure Terraform remote state](#21-configure-terraform-remote-state)
  - [2.2. Configure Terraform provider](#22-configure-terraform-provider)
  - [2.3. Set Terraform variable values](#23-set-terraform-variable-values)
- [3. GitHub Actions](#3-github-actions)
  - [3.1. Create repository secret](#31-create-repository-secret)
  - [3.2. Set environment variable](#32-set-environment-variable)

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

To add S3 bucket policy for "swan-production-terraform-backend" S3 bucket, in AWS Management Console, go to ap-southeast-1 region -> S3 -> Buckets -> General purpose buckets -> swan-production-terraform-backend -> Permissions -> Bucket policy. Click "Edit". Copy and paste the following json. Click "Save changes".
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

### 1.3. Route 53 domain and public hosted zone

A domain called "swanpyaetun.com" must be present in Route 53 Registered domains. A public hosted zone called "swanpyaetun.com" must be present in Route 53 Hosted zones.<br>
Both the domain and the public hosted zone have the following tags:<br>
Project: swan_eks-infrastructure<br>
Environment: Production

## 2. Terraform

### 2.1. Configure Terraform remote state

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
  }
}
```

### 2.2. Configure Terraform provider

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

### 2.3. Set Terraform variable values

In swan_terraform/swan_environments/swan_production/prod.tfvars, set the values for Terraform variables.

## 3. GitHub Actions

### 3.1. Create repository secret

In swanpyaetun/swan_eks-infrastructure repository, go to "Settings" -> Secrets and variables -> Actions.<br>
Create a new repository secret:<br>
Name: SWAN_CI_IAM_ROLE_ARN<br>
Secret: swan_githubactions_terraform IAM role arn from [1.2. Create IAM Role for GitHub Actions to authenticate to AWS](#12-create-iam-role-for-github-actions-to-authenticate-to-aws)

### 3.2. Set environment variable

In .github/workflows/swan_terraform.yml and .github/workflows/swan_terraform_destroy.yml, set the following environment variable:
```yaml
env:
  SWAN_AWS_REGION: "ap-southeast-1"
```