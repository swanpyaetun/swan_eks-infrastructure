{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAPIServerEndpointDiscovery",
      "Effect": "Allow",
      "Resource": "arn:aws:eks:${swan_aws_region}:${swan_aws_account_id}:cluster/${swan_eks_cluster_name}",
      "Action": "eks:DescribeCluster"
    }
  ]
}