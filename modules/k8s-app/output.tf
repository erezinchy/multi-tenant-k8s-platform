output "app_name" {
  value = var.app_name
}

output "service_name" {
  value = kubernetes_service.app_svc.metadata[0].name
}

