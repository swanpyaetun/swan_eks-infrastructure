# Technical Details

## 1. AWS

### 1.1. S3 bucket for Terraform remote state

S3 bucket is used as backend storage for Terraform remote state.

Bucket Versioning is enabled for state recovery in the case of accidental deletions and human error.

S3 bucket is secured by implementing the following practices:<br>
1. Block all public access<br>
2. Enable Bucket Versioning<br>
3. Enable SSE-S3 (Default encryption)

### 1.2. IAM Role for GitHub Actions to authenticate to AWS

GitHub OIDC provider is added in IAM. 

IAM Role is configured to trust GitHub OIDC provider, swanpyaetun organization, and swan_eks-infrastructure repository. IAM Role is created with AdministratorAccess. 

GitHub Actions can now assume IAM Role. 

GitHub Actions authentication to AWS is secured by implementing the following practices:<br>
1. Not storing long-lived IAM user credentials in GitHub<br>
2. Using short-lived OIDC tokens with automatic expiration

## 2. GitHub Actions