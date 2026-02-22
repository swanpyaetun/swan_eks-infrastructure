{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowInterruptionQueueActions",
      "Effect": "Allow",
      "Resource": "${swan_karpenter_interruption_sqs_queue_arn}",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage"
      ]
    }
  ]
}