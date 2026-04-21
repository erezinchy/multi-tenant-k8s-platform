output "gateway_address" {
  description = "The local IP address to access your applications."
  value       = "127.0.0.1"
  # Note: In Minikube with Docker, the tunnel usually maps to localhost/127.0.0.1
}

output "application_routes" {
  description = "List of accessible application endpoints."
  value = {
    for name, config in var.apps : name => "http://localhost${config.route_path}"
  }
}

output "verification_command" {
  description = "Run this to see your routes in the cluster."
  value       = "kubectl get httproute -A"
}