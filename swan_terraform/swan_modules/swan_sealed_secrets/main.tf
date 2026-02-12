resource "helm_release" "swan_sealed_secrets_helm_release" {
  name             = "sealed-secrets"
  repository       = "https://bitnami-labs.github.io/sealed-secrets"
  chart            = "sealed-secrets"
  version          = "2.18.1"
  namespace        = "kube-system"
  create_namespace = true
}