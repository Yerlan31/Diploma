resource "kubernetes_daemonset" "node_exporter" {
  metadata {
    name      = "node-exporter"
    namespace = "kube-system"

    labels = {
      k8s-app = "node-exporter"
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "node-exporter"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "node-exporter"
        }
      }

      spec {
        container {
          name  = "node-exporter"
          image = "prom/node-exporter"

          port {
            name           = "http"
            container_port = 9100
            protocol       = "TCP"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "node_exporter" {
  metadata {
    name      = "node-exporter"
    namespace = "kube-system"

    labels = {
      k8s-app = "node-exporter"
    }
  }

  spec {
    port {
      name      = "http"
      protocol  = "TCP"
      port      = 9100
      node_port = 31111
    }

    selector = {
      k8s-app = "node-exporter"
    }

    type = "NodePort"
  }
}

