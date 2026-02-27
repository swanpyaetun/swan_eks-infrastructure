# Technical Details

## 1. AWS resources for Terraform and GitHub Actions

### 1.1. S3 bucket for Terraform remote state

S3 bucket is used as backend storage for Terraform remote state.

Bucket Versioning is enabled for state recovery in the case of accidental deletions and human error.

S3 bucket is secured by implementing the following practices:
1. Block all public access
2. Enable Bucket Versioning
3. Enable SSE-S3 encryption type (Default encryption)
4. Deny insecure http traffic with S3 bucket policy

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

To view ECR basic scanning result, in AWS Management Console, go to "Elastic Container Registry" -> Private registry -> Repositories. Choose a repository that has container image that you want to view ECR basic scanning result for. Choose an image that you want to view ECR basic scanning result for. Under "Scanning and vulnerabilities", you will see ECR basic scanning result for that image.

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

swan_eks module contains:
1. EKS cluster IAM role
2. EKS cluster
3. EKS node IAM role
4. system EKS node group
5. vpc-cni eks addon
6. coredns eks addon
7. kube-proxy eks addon
8. eks-pod-identity-agent eks addon
9. eks-node-monitoring-agent eks addon
10. access entry for ci IAM role
11. EKS cluster admin IAM role
12. access entry for EKS cluster admin IAM role
13. Argo CD Image Updater IAM role
14. Argo CD Image Updater pod identity association
15. AWS Load Balancer Controller IAM role
16. AWS Load Balancer Controller pod identity association
17. Karpenter interruption SQS queue
18. Karpenter interruption SQS queue policy
19. EventBridge rules
20. Karpenter IAM role
21. Karpenter pod identity association

EKS control plane cross-account ENIs are deployed in private subnets. Public endpoint is enabled for EKS cluster. Private endpoint is enabled for EKS cluster. "API" authentication_mode is used, so access entries can be used in the cluster. Automatically giving cluster admin permissions to the cluster creator is disabled.

System EKS node group nodes are deployed in private subnets. "ON_DEMAND" capacity_type is used. During update, maximum 1 node can be unavailable, and node is created first before deletion. Node auto repair is enabled, maximum 1 node can be repaired in parallel, and node auto repair actions stop if more than 5 nodes are unhealthy. Label and taint are applied to the system EKS node group nodes, so that only system workloads can run on system EKS node group nodes.

vpc-cni eks addon enables pod networking within EKS cluster. Prefix Delegation is enabled to increase the number of IP addresses available to nodes and increase pod density per node. With Prefix Delegation enabled, vpc-cni assigns /28 (16 IP addresses) IPv4 address prefixes, instead of assigning individual IPv4 addresses to ENIs of the nodes. vpc-cni allocates IP addresses to pods from the prefixes assigned to ENIs. vpc-cni pre-allocates a prefix for faster pod startup by maintaining a warm pool. Network policy is enabled in vpc-cni to enforce kubernetes network policies.

coredns eks addon enables service discovery within EKS cluster.

kube-proxy eks addon enables service networking within EKS cluster.

eks-pod-identity-agent eks addon is used, so that IAM roles can be associated with kubernetes service accounts.

eks-node-monitoring-agent eks addon enables automatic detection of node health issues, so more node conditions for EKS node auto repair can be detected.

An access entry is created for ci IAM role, and AmazonEKSClusterAdminPolicy is assigned to ci IAM role.

EKS cluster admin is created as an IAM role. An access entry is created for EKS cluster admin IAM role, and AmazonEKSClusterAdminPolicy is assigned to EKS cluster admin IAM role. 

EKS cluster is secured by implementing the following practices:
1. Envelope encryption is enabled in EKS cluster (Default)
2. Enable private endpoint for EKS api server, so that worker node traffic to EKS api server endpoint will stay within VPC.
3. Automatically giving cluster admin permissions to the cluster creator is disabled
4. System EKS node group nodes are deployed in private subnets
5. vpc-cni enforcing kubernetes network policies
6. Creating EKS cluster admin as an IAM role that have short-term credentials, rather than an IAM user that have long-term credentials

Argo CD Image Updater IAM role is associated with "argocd-image-updater" service account in "argocd" namespace, using eks pod identity.

AWS Load Balancer Controller IAM role is associated with "aws-load-balancer-controller" service account in "kube-system" namespace, using eks pod identity.

Karpenter interruption SQS queue is secured by implementing the following practices:
1. Encrypt data at rest by enabling SSE-SQS encryption type
2. Encrypt data in transit (Default)
3. Deny insecure http traffic with SQS queue policy

SQS queue policy ensures only EventBridge and SQS services can send messages to SQS queue.

EventBridge sends "AWS Health Event", "EC2 Spot Instance Interruption Warning", "EC2 Instance Rebalance Recommendation", and "EC2 Instance State-change Notification" events to the SQS queue. Karpenter reads the events from SQS queue. When Karpenter receives interruption events, it gracefully drains the affected node and provisions a replacement so workloads can be rescheduled.

Karpenter IAM Role is associated with "karpenter" service account in "kube-system" namespace, using eks pod identity.

### 3.4. swan_terraform/swan_modules/swan_helm

swan_helm module contains:
1. Sealed Secrets
2. Argo CD
3. Argo CD Image Updater
4. AWS Load Balancer Controller
5. Metrics Server
6. Karpenter

Sealed Secrets encrypts kubernetes Secrets into “SealedSecrets” that are safe to store in git. Only the controller running in the cluster can decrypt them back into standard Secrets at runtime.

Argo CD continuously synchronizes applications defined in git repository with the kubernetes cluster, ensuring the cluster state matches the declared configuration.

Argo CD Image Updater monitors ECR for new container image tags, updates the container image references in the git repository, and allows argocd to deploy the updated tag to the kubernetes cluster.

AWS Load Balancer Controller watches kubernetes ingress and service objects and creates or updates corresponding AWS load balancers (such as application load balancers and network load balancers).

Metrics Server provides resource usage data (CPU, memory) for nodes and pods, for monitoring and auto-scaling workloads.

Karpenter is a cluster autoscaler that automatically provisions and scales nodes based on workload demand. It observes pending pods and dynamically launches or terminates nodes to optimize cost, and resource utilization.

nodeSelector and toleration are applied to the above resources, so that these resources can run on system EKS node group nodes.

### 3.5. swan_terraform/swan_environments/swan_production/backend.tf

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
S3 state locking is enabled for terraform S3 backend.

### 3.5. swan_terraform/swan_environments/swan_production/prod.tfvars

```hcl
# swan_vpc
swan_vpc_cidr_block            = "10.0.0.0/16"
swan_availability_zones        = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
swan_public_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
swan_public_subnet_tags = {
  "kubernetes.io/role/elb" = "1"
}
swan_private_subnet_cidr_blocks = ["10.0.64.0/18", "10.0.128.0/18", "10.0.192.0/18"]
swan_private_subnet_tags = {
  "kubernetes.io/role/internal-elb" = "1"
  # for Karpenter auto-discovery
  "karpenter.sh/discovery" = "swan_production_eks_cluster"
}
```
To have a lot of ip addresses, /16 is used for VPC which gives 65536 ip addresses, and /18 is used for private subnets which gives 16384 ip addresses per private subnet.

Subnets are created across 3 availability zones.

The public subnets tag "kubernetes.io/role/elb" signals AWS Load Balancer Controller in EKS cluster that these public subnets are for internet-facing load balancers.

The private subnets tag "kubernetes.io/role/internal-elb" signals AWS Load Balancer Controller in EKS cluster that these private subnets are for internal load balancers. The private subnets tag "karpenter.sh/discovery" is for Karpenter auto-discovery, so Karpenter can launch EC2 nodes in these private subnets for swan_production_eks_cluster.

```hcl
swan_system_eks_node_group_desired_size = 2
swan_system_eks_node_group_min_size     = 2
swan_system_eks_node_group_max_size     = 2
```
High availbility in system EKS node group is achieved by implementing the following practices:
1. Setting 2 nodes as minimum size, and 2 nodes as desired_size