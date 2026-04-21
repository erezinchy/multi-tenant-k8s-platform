# 1. Create the Minikube Cluster
resource "minikube_cluster" "this" {
  driver             = "docker"
  cluster_name       = "dev-cluster"
  nodes              = 1
  kubernetes_version = "v1.28.3"
  addons             = ["ingress", "default-storageclass", "storage-provisioner"]
  wait_timeout       = 20
}

# 2. Install Gateway API CRDs & Envoy Controller [cite: 2, 3]
resource "terraform_data" "gateway_setup" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
      kubectl apply -f https://github.com/envoyproxy/gateway/releases/download/v1.0.1/install.yaml
      kubectl rollout status deployment/envoy-gateway -n envoy-gateway-system --timeout=90s
    EOT
  }
  depends_on = [minikube_cluster.this]
}

# 3. Create the GatewayClass (The missing piece!)
resource "kubernetes_manifest" "envoy_gateway_class" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"
    metadata = {
      name = "envoy"
    }
    spec = {
      controllerName = "gateway.envoyproxy.io/gatewayclass-controller"
    }
  }
  depends_on = [terraform_data.gateway_setup]
}

# 4. Create the Gateway Instance
resource "kubernetes_manifest" "main_gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "main-gateway"
      namespace = "default"
    }
    spec = {
      gatewayClassName = "envoy"
      listeners = [{
        name     = "http"
        protocol = "HTTP"
        port     = 80
        allowedRoutes = {
          namespaces = { from = "Same" }
        }
      }]
    }
  }

  computed_fields = ["spec.infrastructure"]

  depends_on = [kubernetes_manifest.envoy_gateway_class]
}

# 5. Deploy Apps
module "apps" {
  source   = "../../modules/k8s-app"
  for_each = var.apps

  app_name     = each.key
  image        = each.value.image
  replicas     = each.value.replicas
  route_path   = each.value.route_path
  gateway_name = "main-gateway"

  depends_on = [kubernetes_manifest.main_gateway]
}