---
config:
  registries:
  - name: ECR
    api_url: https://${swan_aws_account_id}.dkr.ecr.${swan_aws_region}.amazonaws.com
    prefix: ${swan_aws_account_id}.dkr.ecr.${swan_aws_region}.amazonaws.com
    ping: yes
    insecure: no
    credentials: ext:/scripts/auth1.sh
    credsexpire: 10h

authScripts:
  enabled: true
  scripts:
    auth1.sh: |
      #!/bin/sh
      aws ecr --region ${swan_aws_region} get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d

serviceAccount:
  name: argocd-image-updater