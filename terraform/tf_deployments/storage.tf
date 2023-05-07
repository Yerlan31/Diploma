resource "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }

  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_persistent_volume_claim" "local_volume" {
  metadata {
    name = "local-volume"
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    storage_class_name = "local-storage"
  }
}

resource "kubernetes_persistent_volume" "pv_local" {
  metadata {
    name = "pv-local"
  }

  spec {
    capacity = {
      storage = "1Gi"
    }

    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "local-storage"
    volume_mode                      = "Filesystem"

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = ["yervm"]
          }
        }
      }
    }
  }
}

