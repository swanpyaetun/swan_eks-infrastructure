# Prerequisites

## Table of Contents

- [1. AWS](#1-aws)
  - [1.1. Route 53 domain and public hosted zone](#11-route-53-domain-and-public-hosted-zone)
  - [1.2. Create AWS resources required for swanpyaetun/swan_eks-infrastructure-for-opentelemetry-demo Project, and swanpyaetun/swan_opentelemetry-demo Project](#12-create-aws-resources-required-for-swanpyaetunswan_eks-infrastructure-for-opentelemetry-demo-project-and-swanpyaetunswan_opentelemetry-demo-project)
- [2. GitHub Actions](#2-github-actions)
  - [2.1. Create repository secret](#21-create-repository-secret)

## 1. AWS

### 1.1. Route 53 domain and public hosted zone

A domain called "swanpyaetun.com" must be present in Route 53 Registered domains. A public hosted zone called "swanpyaetun.com" must be present in Route 53 Hosted zones.

### 1.2. Create AWS resources required for swanpyaetun/swan_eks-infrastructure-for-opentelemetry-demo Project, and swanpyaetun/swan_opentelemetry-demo Project

```bash
cd ~/Desktop/
git clone git@github.com:swanpyaetun/swan_eks-infrastructure-for-opentelemetry-demo.git
```
Go to ~/Desktop/ and clone the [https://github.com/swanpyaetun/swan_eks-infrastructure-for-opentelemetry-demo](https://github.com/swanpyaetun/swan_eks-infrastructure-for-opentelemetry-demo) repository.
<br><br>

```bash
cd ~/Desktop/swan_eks-infrastructure-for-opentelemetry-demo/swan_terraform/swan_environments/swan_prerequisites/
```
Go to ~/Desktop/swan_eks-infrastructure-for-opentelemetry-demo/swan_terraform/swan_environments/swan_prerequisites/ directory.
<br><br>

```hcl
# terraform {
#   backend "s3" {
#     region       = "ap-southeast-1"
#     bucket       = "swan-terraform-backend-655355946217-ap-southeast-1-an"
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
Run this command to create AWS resources required for swanpyaetun/swan_eks-infrastructure-for-opentelemetry-demo project, and swanpyaetun/swan_opentelemetry-demo project.<br>
S3 bucket and CI IAM role are created for swanpyaetun/swan_eks-infrastructure-for-opentelemetry-demo project.<br>
CI IAM role, private ECR repositories, and ACM certificate are created for swanpyaetun/swan_opentelemetry-demo project.
<br><br>

```hcl
terraform {
  backend "s3" {
    region       = "ap-southeast-1"
    bucket       = "swan-terraform-backend-655355946217-ap-southeast-1-an"
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

```bash
aws iam get-role --role-name swan_githubactions_terraform_iam_role --query 'Role.Arn' --output text
```
Run this command to get "swan_githubactions_terraform_iam_role" arn.

In swanpyaetun/swan_eks-infrastructure-for-opentelemetry-demo repository, go to "Settings" -> Security and quality -> Secrets and variables -> Actions.<br>
Create a new repository secret:<br>
Name: SWAN_CI_IAM_ROLE_ARN<br>
Secret: "swan_githubactions_terraform_iam_role" arn