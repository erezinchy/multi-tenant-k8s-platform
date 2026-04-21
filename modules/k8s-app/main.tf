resource "kubernetes_deployment" "app" {
  metadata {
    name = var.app_name
    labels = { app = var.app_name }
  }

  spec {
    replicas = var.replicas
    selector { match_labels = { app = var.app_name } }

    template {
      metadata { labels = { app = var.app_name } }
      spec {
        container {
          name  = var.app_name
          image = var.image

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          args = ["-text=App: ${var.app_name} | Pod: $(POD_NAME) | IP: $(POD_IP)"]
          port { container_port = 5678 }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_svc" {
  metadata { name = "${var.app_name}-svc" }
  spec {
    selector = { app = var.app_name }
    port {
      port        = 80
      target_port = 5678
    }
  }
}

# This replaces the Ingress. It tells the Gateway how to route traffic to this specific app.
resource "kubernetes_manifest" "app_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "${var.app_name}-route"
      namespace = "default"
    }
    spec = {
      parentRefs = [{
        name = var.gateway_name
        namespace = "default"
      }]
      rules = [{
        matches = [{
          path = {
            type  = "PathPrefix"
            value = var.route_path
          }
        }]
        backendRefs = [{
          name = kubernetes_service.app_svc.metadata[0].name
          port = 80
        }]
      }]
    }
  }
}