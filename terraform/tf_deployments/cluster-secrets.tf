resource "kubernetes_secret" "cluster_secrets" {
  metadata {
    name = "cluster-secrets"
  }

  data = {
    db-password = "mongopassword"

    db-user = "mongouser"
  }

  type = "Opaque"
}

