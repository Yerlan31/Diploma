resource "kubernetes_ingress_v1" "minimal_ingress" {
  metadata {
    name      = "minimal-ingress"
    namespace = "kube-system"

    annotations = {
      "kubernetes.io/ingress.allow-http" = "true"
    }
  }

  spec {
    rule {
      host = "jenkins.bmstu.ru"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "jenkins-service"

              port {
                number = 8080
              }
            }
          }
        }
      }
    }

    rule {
      host = "prometheus.bmstu.ru"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "prometheus"

              port {
                number = 9090
              }
            }
          }
        }
      }
    }

    rule {
      host = "grafana.bmstu.ru"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "grafana"

              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}

