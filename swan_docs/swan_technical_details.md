# Technical Details

## 1. AWS resources for Terraform and GitHub Actions

### 1.1. S3 bucket for Terraform remote state

S3 bucket is used as backend storage for Terraform remote state.

Bucket Versioning is enabled for state recovery in the case of accidental deletions and human error.

S3 bucket is secured by implementing the following practices:
1. Block all public access
2. Enable Bucket Versioning
3. Enable SSE-S3 encryption type (Default encryption)

### 1.2. IAM Role for GitHub Actions to authenticate to AWS

GitHub OIDC provider is added in IAM. 

IAM Role is configured to trust GitHub OIDC provider, swanpyaetun organization, and swan_eks-infrastructure repository. IAM Role is created with AdministratorAccess. 

GitHub Actions can now assume IAM Role. 

GitHub Actions authentication to AWS is secured by implementing the following practices:
1. Not storing long-lived IAM user credentials in GitHub
2. Using short-lived OIDC tokens with automatic expiration

## 2. GitHub Actions

### 2.1. .github/workflows/swan_terraform.yml

"Provision AWS Infrastructure using Terraform" pipeline can be triggered in 3 ways:
1. The CI/CD pipeline runs when a pull request is opened against the main branch.
2. The CI/CD pipeline runs when a direct push is made to the main branch.
3. The CI/CD pipeline runs when a user manually triggers it.

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

### 2.2. .github/workflows/swan_terraform_destroy.yml

"Terraform Destroy" pipeline runs when a user manually triggers it.

swan_terraform_destroy job does the following steps:
1. checkout repository
2. set up terraform in the runner
3. configure aws credentials using oidc
4. terraform init
5. delete all terraform resources

## 3. Terraform

Related resources are packaged into individual terraform modules, so that the same infrasturcture can be created easier and faster, and configurations can be standardized across environments and teams.

### 3.1. swan_terraform/swan_modules/swan_ecr

swan_ecr module contains:
1. private ECR repositories
2. ECR lifecycle policy for each private ECR repository, which only keeps latest 30 container images
3. ECR basic scanning for private ECR repositories

Container images in private ECR repositories are secured by implementing the following practices:
1. Using private ECR repositories
2. Enable AES256 encryption_type (Default encryption) for private ECR repositories
3. ECR basic scanning is configured (Default)
4. SCAN_ON_PUSH is configured for private ECR repositories

ECR basic scanning is a free service. It only scans for OS vulnerabilities, not software vulnerabilities.

### 3.2. swan_terraform/swan_modules/swan_vpc

swan_vpc module contains:
1. VPC
2. public subnets
3. private subnets
4. internet gateway
5. regional NAT gateway
6. public route tables
7. private route tables

Internet gateway allows both inbound and outbound traffic between internet and public subnets.
Regional NAT gateway only allows outbound traffic from private subnets to internet.

Resources in private subnets are secured by implementing the following practices:
1. Using regional NAT gateway to disable public access from the internet

High availbility in NAT gateway is achieved by implementing the following practices:
1. Using NAT gateway in Regional availability_mode

Regional NAT Gateway with auto mode is enabled by not specifying availability_zone_address argument in aws_nat_gateway terraform resource. Regional NAT gateway with auto mode will automatically expand to new AZs and associate EIPs upon detection of an elastic network interface. This reduces management overhead.

### 3.3. swan_terraform/swan_modules/swan_eks