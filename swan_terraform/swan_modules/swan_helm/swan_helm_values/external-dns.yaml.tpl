---
serviceAccount:
  name: external-dns

nodeSelector:
  workload-type: "system"

tolerations:
- key: "workload-type"
  operator: "Equal"
  value: "system"
  effect: "NoSchedule"

domainFilters:
  - ${swan_domain}