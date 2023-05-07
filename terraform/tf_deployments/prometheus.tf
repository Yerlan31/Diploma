resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "kube-system"

    labels = {
      name = "prometheus-deployment"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }

      spec {
        volume {
          name      = "data"
          empty_dir = {}
        }

        volume {
          name = "config-volume"

          config_map {
            name = "prometheus-config"
          }
        }

        container {
          name    = "prometheus"
          image   = "prom/prometheus:v2.42.0"
          command = ["/bin/prometheus"]
          args    = ["--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus", "--storage.tsdb.retention=24h"]

          port {
            container_port = 9090
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu = "500m"

              memory = "2500Mi"
            }

            requests = {
              cpu = "100m"

              memory = "100Mi"
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/prometheus"
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/prometheus"
          }
        }

        service_account_name = "prometheus"
      }
    }
  }
}

resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "kube-system"

    labels = {
      app = "prometheus"
    }
  }

  spec {
    port {
      port        = 9090
      target_port = "9090"
      node_port   = 30003
    }

    selector = {
      app = "prometheus"
    }

    type = "NodePort"
  }
}

resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = "kube-system"
  }

  data = {
    "prometheus.rules" = "groups:\n- name: devopscube demo alert\n  rules:\n  - alert: InstanceDown\n    expr: up{job=\"jenkins\"} == 0\n  - alert: High Pod Memory\n    expr: sum(container_memory_usage_bytes) > 1\n    for: 1m\n    labels:\n      severity: slack\n    annotations:\n      summary: High Memory Usage"

    "prometheus.yml" = "global:\n  scrape_interval:     15s\n  evaluation_interval: 15s\n\nrule_files:\n  - /etc/prometheus/prometheus.rules\n\nalerting:\n  alertmanagers:\n  - scheme: http\n    static_configs:\n    - targets:\n      - \"alertmanager.kube-system.svc:9093\"\n\nscrape_configs:\n- job_name: 'kubernetes-apiservers'\n  kubernetes_sd_configs:\n  - role: endpoints\n  scheme: https\n  tls_config:\n    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt\n  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token\n  relabel_configs:\n  - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]\n    action: keep\n    regex: default;kubernetes;https\n\n- job_name: 'node-exporter'\n  kubernetes_sd_configs:\n    - role: endpoints\n  relabel_configs:\n  - source_labels: [__meta_kubernetes_endpoints_name]\n    regex: 'node-exporter'\n    action: keep\n\n- job_name: 'kubernetes-nodes'\n  kubernetes_sd_configs:\n  - role: node\n  scheme: https\n  tls_config:\n    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt\n  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token\n  relabel_configs:\n  - action: labelmap\n    regex: __meta_kubernetes_node_label_(.+)\n  - target_label: __address__\n    replacement: kubernetes.default.svc:443\n  - source_labels: [__meta_kubernetes_node_name]\n    regex: (.+)\n    target_label: __metrics_path__\n    replacement: /api/v1/nodes/$${1}/proxy/metrics\n\n- job_name: 'kubernetes-cadvisor'\n  kubernetes_sd_configs:\n  - role: node\n  scheme: https\n  tls_config:\n    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt\n  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token\n  relabel_configs:\n  - action: labelmap\n    regex: __meta_kubernetes_node_label_(.+)\n  - target_label: __address__\n    replacement: kubernetes.default.svc:443\n  - source_labels: [__meta_kubernetes_node_name]\n    regex: (.+)\n    target_label: __metrics_path__\n    replacement: /api/v1/nodes/$${1}/proxy/metrics/cadvisor\n\n- job_name: 'kubernetes-service-endpoints'\n  kubernetes_sd_configs:\n  - role: endpoints\n  relabel_configs:\n  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]\n    action: keep\n    regex: true\n  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]\n    action: replace\n    target_label: __scheme__\n    regex: (https?)\n  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]\n    action: replace\n    target_label: __metrics_path__\n    regex: (.+)\n  - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]\n    action: replace\n    target_label: __address__\n    regex: ([^:]+)(?::\\d+)?;(\\d+)\n    replacement: $1:$2\n  - action: labelmap\n    regex: __meta_kubernetes_service_label_(.+)\n  - source_labels: [__meta_kubernetes_namespace]\n    action: replace\n    target_label: kubernetes_namespace\n  - source_labels: [__meta_kubernetes_service_name]\n    action: replace\n    target_label: kubernetes_name\n\n- job_name: 'kubernetes-services'\n  kubernetes_sd_configs:\n  - role: service\n  metrics_path: /probe\n  params:\n    module: [http_2xx]\n  relabel_configs:\n  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_probe]\n    action: keep\n    regex: true\n  - source_labels: [__address__]\n    target_label: __param_target\n  - target_label: __address__\n    replacement: blackbox-exporter.example.com:9115\n  - source_labels: [__param_target]\n    target_label: instance\n  - action: labelmap\n    regex: __meta_kubernetes_service_label_(.+)\n  - source_labels: [__meta_kubernetes_namespace]\n    target_label: kubernetes_namespace\n  - source_labels: [__meta_kubernetes_service_name]\n    target_label: kubernetes_name\n\n- job_name: 'kubernetes-ingresses'\n  kubernetes_sd_configs:\n  - role: ingress\n  relabel_configs:\n  - source_labels: [__meta_kubernetes_ingress_annotation_prometheus_io_probe]\n    action: keep\n    regex: true\n  - source_labels: [__meta_kubernetes_ingress_scheme,__address__,__meta_kubernetes_ingress_path]\n    regex: (.+);(.+);(.+)\n    replacement: $${1}://$${2}$${3}\n    target_label: __param_target\n  - target_label: __address__\n    replacement: blackbox-exporter.example.com:9115\n  - source_labels: [__param_target]\n    target_label: instance\n  - action: labelmap\n    regex: __meta_kubernetes_ingress_label_(.+)\n  - source_labels: [__meta_kubernetes_namespace]\n    target_label: kubernetes_namespace\n  - source_labels: [__meta_kubernetes_ingress_name]\n    target_label: kubernetes_name\n\n- job_name: 'kubernetes-pods'\n  kubernetes_sd_configs:\n  - role: pod\n  relabel_configs:\n  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]\n    action: keep\n    regex: true\n  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]\n    action: replace\n    target_label: __metrics_path__\n    regex: (.+)\n  - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]\n    action: replace\n    regex: ([^:]+)(?::\\d+)?;(\\d+)\n    replacement: $1:$2\n    target_label: __address__\n  - action: labelmap\n    regex: __meta_kubernetes_pod_label_(.+)\n  - source_labels: [__meta_kubernetes_namespace]\n    action: replace\n    target_label: kubernetes_namespace\n  - source_labels: [__meta_kubernetes_pod_name]\n    action: replace\n    target_label: kubernetes_pod_name\n"
  }
}

resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name = "prometheus"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "services", "endpoints", "pods"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["extensions"]
    resources  = ["ingresses"]
  }

  rule {
    verbs             = ["get"]
    non_resource_urls = ["/metrics"]
  }
}

resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "prometheus"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "prometheus"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "prometheus"
  }
}

