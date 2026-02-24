# Instructions to set up the project

## 1. AWS

### 1.1. Create S3 bucket for Terraform remote state

In AWS Management Console, create a S3 bucket in ap-southeast-1 region with the following configurations: <br>
General configuration: <br>
> Bucket type: General purpose <br>
> Bucket name: swan-production-terraform-backend <br>
Object Ownership:
    Object Ownership: ACLs disabled (recommended)
Block Public Access settings for this bucket:
    Block all public access
Bucket Versioning:
    Bucket Versioning: Enable
Tags:
    Project: swan_eks-infrastructure
    Environment: Production
Default encryption:
    Encryption type: Server-side encryption with Amazon S3 managed keys (SSE-S3)
    Bucket Key: Enable

### 1.2. Create IAM Role for GitHub Actions to authenticate to AWS

In AWS Management Console, add an IAM Identity provider with the following configurations:
Provider details:
    Provider type: OpenID Connect
    Provider URL: https://token.actions.githubusercontent.com
    Audience: sts.amazonaws.com
Tags:
    Project: swan_eks-infrastructure
    Environment: Production

In AWS Management Console, create an IAM Role with the following configurations:
Trusted entity type:
    Web identity
Web identity:
    Identity provider: token.actions.githubusercontent.com
    Audience: sts.amazonaws.com
    GitHub organization: swanpyaetun
    GitHub repository: swan_eks-infrastructure
Permissions policies:
    AdministratorAccess
Role details:
    Role name: swan_githubactions_terraform
Tags:
    Project: swan_eks-infrastructure
    Environment: Production

## 2. GitHub Actions

### 2.1. Create repository secret

Go to swanpyaetun/swan_eks-infrastructure repository -> Settings -> Secrets and variables -> Actions.

Create a new repository secret:
Name: SWAN_CI_IAM_ROLE_ARN
Secret: swan_githubactions_terraform IAM Role arn from [1.2. Create IAM Role for GitHub Actions to authenticate to AWS](#12-create-iam-role-for-github-actions-to-authenticate-to-aws)

### 2.2. Set environment variable

In .github/workflows/swan_terraform.yml and .github/workflows/swan_terraform_destroy.yml, set the following environment variable:
```yaml
env:
  SWAN_AWS_REGION: "ap-southeast-1"
```

## 3. Terraform

### 3.1. Configure Terraform remote state

In swan_terraform/swan_environments/swan_production/backend.tf, set the following for "s3" backend:
<pre>
<a href="#11-create-s3-bucket-for-terraform-remote-state">bucket: "swan-production-terraform-backend"</a>
key: "swan_production/terraform.tfstate"
<a href="#11-create-s3-bucket-for-terraform-remote-state">region: "ap-southeast-1"</a>
</pre>
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