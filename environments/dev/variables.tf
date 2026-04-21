variable "aws_region" {
  type        = string
  description = "The AWS region for the S3 backend"
  default     = "eu-west-2"
}

variable "aws_profile" {
  type        = string
  description = "The AWS profile to use"
  default     = "personal"
}

variable "apps" {
  type = map(object({
    image      = string
    replicas   = number
    route_path = string
  }))
  description = "Map of applications to deploy from tfvars"
}