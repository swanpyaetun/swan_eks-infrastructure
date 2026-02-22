{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowScopedEC2InstanceAccessActions",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ec2:${swan_aws_region}::image/*",
        "arn:aws:ec2:${swan_aws_region}::snapshot/*",
        "arn:aws:ec2:${swan_aws_region}:*:security-group/*",
        "arn:aws:ec2:${swan_aws_region}:*:subnet/*",
        "arn:aws:ec2:${swan_aws_region}:*:capacity-reservation/*"
      ],
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet"
      ]
    },
    {
      "Sid": "AllowScopedEC2LaunchTemplateAccessActions",
      "Effect": "Allow",
      "Resource": "arn:aws:ec2:${swan_aws_region}:*:launch-template/*",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${swan_eks_cluster_name}": "owned"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.sh/nodepool": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedEC2InstanceActionsWithTags",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ec2:${swan_aws_region}:*:fleet/*",
        "arn:aws:ec2:${swan_aws_region}:*:instance/*",
        "arn:aws:ec2:${swan_aws_region}:*:volume/*",
        "arn:aws:ec2:${swan_aws_region}:*:network-interface/*",
        "arn:aws:ec2:${swan_aws_region}:*:launch-template/*",
        "arn:aws:ec2:${swan_aws_region}:*:spot-instances-request/*"
      ],
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet",
        "ec2:CreateLaunchTemplate"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes.io/cluster/${swan_eks_cluster_name}": "owned",
          "aws:RequestTag/eks:eks-cluster-name": "${swan_eks_cluster_name}"
        },
        "StringLike": {
          "aws:RequestTag/karpenter.sh/nodepool": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedResourceCreationTagging",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ec2:${swan_aws_region}:*:fleet/*",
        "arn:aws:ec2:${swan_aws_region}:*:instance/*",
        "arn:aws:ec2:${swan_aws_region}:*:volume/*",
        "arn:aws:ec2:${swan_aws_region}:*:network-interface/*",
        "arn:aws:ec2:${swan_aws_region}:*:launch-template/*",
        "arn:aws:ec2:${swan_aws_region}:*:spot-instances-request/*"
      ],
      "Action": "ec2:CreateTags",
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes.io/cluster/${swan_eks_cluster_name}": "owned",
          "aws:RequestTag/eks:eks-cluster-name": "${swan_eks_cluster_name}",
          "ec2:CreateAction": [
            "RunInstances",
            "CreateFleet",
            "CreateLaunchTemplate"
          ]
        },
        "StringLike": {
          "aws:RequestTag/karpenter.sh/nodepool": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedResourceTagging",
      "Effect": "Allow",
      "Resource": "arn:aws:ec2:${swan_aws_region}:*:instance/*",
      "Action": "ec2:CreateTags",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${swan_eks_cluster_name}": "owned"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.sh/nodepool": "*"
        },
        "StringEqualsIfExists": {
          "aws:RequestTag/eks:eks-cluster-name": "${swan_eks_cluster_name}"
        },
        "ForAllValues:StringEquals": {
          "aws:TagKeys": [
            "eks:eks-cluster-name",
            "karpenter.sh/nodeclaim",
            "Name"
          ]
        }
      }
    },
    {
      "Sid": "AllowScopedDeletion",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ec2:${swan_aws_region}:*:instance/*",
        "arn:aws:ec2:${swan_aws_region}:*:launch-template/*"
      ],
      "Action": [
        "ec2:TerminateInstances",
        "ec2:DeleteLaunchTemplate"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${swan_eks_cluster_name}": "owned"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.sh/nodepool": "*"
        }
      }
    }
  ]
}