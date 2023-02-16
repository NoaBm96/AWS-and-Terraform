terraform {
  backend "s3" {
    bucket  = "noabm-remote-state-terraform"
    key     = "~/AWS-and-Terraform/VPC-assignment2/terraform.tfstate"
    region  = "us-east-1"
    profile = "noa-admin"
  }
}