variable "app_name" {
  type = string
}

variable "image" { # Changed from app_image to image
  type = string
}

variable "replicas" {
  type = number
}

variable "route_path" {
  type = string
}

variable "gateway_name" { # Added this so dev/main.tf can pass it in
  type = string
}