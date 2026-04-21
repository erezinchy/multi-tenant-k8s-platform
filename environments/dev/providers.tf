terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "~> 0.3.0"
    }
  }
}


provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# This provider config is dynamic: it waits for the cluster to be created
provider "kubernetes" {
  host = minikube_cluster.this.host

  client_certificate     = minikube_cluster.this.client_certificate
  client_key             = minikube_cluster.this.client_key
  cluster_ca_certificate = minikube_cluster.this.cluster_ca_certificate
}
