aws_region = "eu-west-2"

apps = {
  "app-alpha" = {
    image      = "hashicorp/http-echo:latest"
    replicas   = 2
    route_path = "/alpha"
  },
  "app-beta" = {
    image      = "hashicorp/http-echo:latest"
    replicas   = 1
    route_path = "/beta"
  }
}