terraform {
  backend "s3" {
    bucket         = "terraform-state-storage-erez"
    key            = "dev_env/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    use_lockfile   = true # Replaces DynamoDB for state locking in Terraform 1.10+
  }
}