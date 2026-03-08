# Prerequisites

## Table of Contents

- [1. Terraform Prerequisites](#1-terraform-prerequisites)
  - [1.1. Route 53 domain and public hosted zone](#11-route-53-domain-and-public-hosted-zone)
  - [1.2. Create AWS resources required for swanpyaetun/swan_eks-infrastructure Project, and swanpyaetun/swan_polyglot-microservices-application Project](#12-create-aws-resources-required-for-swanpyaetunswan_eks-infrastructure-project-and-swanpyaetunswan_polyglot-microservices-application-project)
- [2. GitHub Actions](#2-github-actions)
  - [2.1. Create repository secret](#21-create-repository-secret)

## 1. Terraform Prerequisites

### 1.1. Route 53 domain and public hosted zone

A domain called "swanpyaetun.com" must be present in Route 53 Registered domains. A public hosted zone called "swanpyaetun.com" must be present in Route 53 Hosted zones.

### 1.2. Create AWS resources required for swanpyaetun/swan_eks-infrastructure Project, and swanpyaetun/swan_polyglot-microservices-application Project

```bash
cd ~/Desktop/
git clone git@github.com:swanpyaetun/swan_eks-infrastructure.git
```
Go to ~/Desktop/ and clone the [https://github.com/swanpyaetun/swan_eks-infrastructure](https://github.com/swanpyaetun/swan_eks-infrastructure) repository.
<br><br>

```bash
cd ~/Desktop/swan_eks-infrastructure/swan_terraform/swan_environments/swan_prerequisites/
```
Go to ~/Desktop/swan_eks-infrastructure/swan_terraform/swan_environments/swan_prerequisites/ directory.
<br><br>

```hcl
# terraform {
#   backend "s3" {
#     region       = "ap-southeast-1"
#     bucket       = "swan-terraform-backend"
#     key          = "swan_prerequisites/terraform.tfstate"
#     use_lockfile = true # s3 state locking
#   }
# }
```
Comment out backend.tf file, since S3 bucket has not been created yet.
<br><br>

```bash
terraform init
```
Run this command.
<br><br>

```bash
terraform apply -auto-approve -var-file=prerequisites.tfvars
```
Run this command to create AWS resources required for swanpyaetun/swan_eks-infrastructure project, and swanpyaetun/swan_polyglot-microservices-application project.<br>
S3 bucket, GitHub OIDC provider, and CI IAM role is created for swanpyaetun/swan_eks-infrastructure project.<br>
CI IAM role, Private ECR Repositories, and ACM Certificate is created for swanpyaetun/swan_polyglot-microservices-application project.<br>
The above command will generate the following Terraform outputs: swan_acm_certificate_arn, swan_githubactions_ecr_iam_role_arn, and swan_githubactions_terraform_iam_role_arn. Copy the Terraform outputs.
<br><br>

```hcl
terraform {
  backend "s3" {
    region       = "ap-southeast-1"
    bucket       = "swan-terraform-backend"
    key          = "swan_prerequisites/terraform.tfstate"
    use_lockfile = true # s3 state locking
  }
}
```
Uncomment backend.tf file, since S3 bucket has already been created.
<br><br>

```bash
terraform init -migrate-state
```
Run this command to migrate "local" backend to "s3" backend. Enter "yes".
<br><br>

```bash
rm -rf .terraform/ .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
```
You can clean up the directory.

## 2. GitHub Actions

### 2.1. Create repository secret

You can get "swan_githubactions_terraform_iam_role" arn in 3 ways:
1. Copied Terraform outputs from [1.2. Create AWS resources required for swanpyaetun/swan_eks-infrastructure Project, and swanpyaetun/swan_polyglot-microservices-application Project](#12-create-aws-resources-required-for-swanpyaetunswan_eks-infrastructure-project-and-swanpyaetunswan_polyglot-microservices-application-project)
2. aws iam get-role --role-name swan_githubactions_terraform_iam_role --query 'Role.Arn' --output text
3. AWS Management Console

In swanpyaetun/swan_eks-infrastructure repository, go to "Settings" -> Secrets and variables -> Actions.<br>
Create a new repository secret:<br>
Name: SWAN_CI_IAM_ROLE_ARN<br>
Secret: "swan_githubactions_terraform_iam_role" arn