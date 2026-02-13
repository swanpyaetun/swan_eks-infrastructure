---
serviceAccount:
  name: argocd-image-updater

authScripts:
  enabled: true
  scripts:
    auth1.sh: |
      #!/bin/sh
      aws ecr --region ${swan_aws_region} get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d

config:
  registries:
  - name: ECR
    api_url: https://${swan_ecr_registry}
    prefix: ${swan_ecr_registry}
    ping: yes
    insecure: no
    credentials: ext:/scripts/auth1.sh
    credsexpire: 10h