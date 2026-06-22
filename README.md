# swanpyaetun/swan_eks-infrastructure-for-opentelemetry-demo

# Automating EKS Infrastructure Provisioning with Terraform and GitHub Actions

![](swan_docs/swan_images/architecture_diagram.png)

- Tools used: GitHub Actions, Terraform, AWS, EKS, Helm, Argo CD, Argo CD Image Updater, AWS Load Balancer Controller, External DNS, Karpenter
- Provision EKS infrastructure with Terraform
- Set up GitHub Actions CI/CD pipelines to automate infrastructure provisioning
- Secure GitHub Actions authentication to AWS by using short-lived OIDC tokens with automatic expiration, instead of storing long-lived IAM user credentials in GitHub
- Secure container images in private ECR repositories by enabling AES256 encryption type (Default encryption), and ECR basic scanning on every container image push to scan for OS vulnerabilities
- Secure S3 bucket by blocking all public access, enabling Bucket Versioning, enabling SSE-S3 encryption type (Default encryption), and denying insecure http traffic with S3 bucket policy
- Use regional NAT gateway to be highly available across AZs
- Secure EKS cluster by enabling envelope encryption in EKS cluster (Default), enabling private endpoint for EKS api server, so that worker node traffic to EKS api server endpoint will stay within VPC, and creating EKS cluster admin as an IAM role that have short-term credentials, rather than an IAM user that have long-term credentials
- Secure Karpenter interruption SQS queue by encrypting data at rest by enabling SSE-SQS encryption type, encrypting data in transit (Default), and denying insecure http traffic with SQS queue policy
- Monitor ECR for new container image tags, and update the container image tags in the git repository with Argo CD Image Updater
- Create internet-facing ALB for Kubernetes ingress with AWS Load Balancer Controller
- Create DNS records in Route 53 public hosted zone with External DNS

## Table of Contents

- [1. Prerequisites](#1-see-prerequisites)
- [2. Technical Details](#2-see-technical-details)
- [3. Instructions](#3-instructions)
- [4. Additional Information](#4-additional-information)

## 1. See [Prerequisites](swan_docs/swan_docs//swan_prerequisites.md)

## 2. See [Technical Details](swan_docs/swan_docs/swan_technical_details.md)

## 3. Instructions

Run "Provision AWS Infrastructure with Terraform" pipeline to create EKS Infrastructure.<br>
"Provision AWS Infrastructure with Terraform" pipeline can be triggered in 1 way:
1. The CI/CD pipeline runs when a user manually triggers it.
<br>

Run "Terraform Destroy" pipeline to destroy EKS Infrastructure.<br>
"Terraform Destroy" pipeline can be triggered in 1 way:
1. The CI/CD pipeline runs when a user manually triggers it.

## 4. Additional Information

GitHub Actions CI/CD pipelines for microservices, and Kubernetes manifests: [https://github.com/swanpyaetun/swan_opentelemetry-demo](https://github.com/swanpyaetun/swan_opentelemetry-demo)