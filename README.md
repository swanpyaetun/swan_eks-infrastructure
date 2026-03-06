# swanpyaetun/swan_eks-infrastructure

# Automating EKS Infrastructure Provisioning with Terraform and GitHub Actions

## Table of Contents

- [1. Prerequisites](#1-see-prerequisites)
- [2. Technical Details](#2-see-technical-details)
- [3. Instructions](#3-instructions)
- [4. Additional Information](#4-additional-information)

## 1. See [Prerequisites](swan_docs/swan_prerequisites.md)

## 2. See [Technical Details](swan_docs/swan_technical_details.md)

## 3. Instructions

Run "Provision AWS Infrastructure using Terraform" pipeline to create EKS Infrastructure.<br>
"Provision AWS Infrastructure using Terraform" pipeline can be triggered in 3 ways:
1. The CI/CD pipeline runs when a pull request is opened against the main branch.
2. The CI/CD pipeline runs when a direct push is made to the main branch.
3. In swanpyaetun/swan_eks-infrastructure repository, go to "Actions" -> Provision AWS Infrastructure using Terraform. Click "Run workflow", and click "Run workflow" to run the CI/CD pipeline.

Run "Terraform Destroy" pipeline to destroy EKS Infrastructure.<br>
In swanpyaetun/swan_eks-infrastructure repository, go to "Actions" -> Terraform Destroy. Click "Run workflow", and click "Run workflow" to run "Terraform Destroy" pipeline.

## 4. Additional Information

GitHub Actions CI/CD pipelines for microservices, and Kubernetes manifests: [https://github.com/swanpyaetun/swan_polyglot-microservices-application](https://github.com/swanpyaetun/swan_polyglot-microservices-application)