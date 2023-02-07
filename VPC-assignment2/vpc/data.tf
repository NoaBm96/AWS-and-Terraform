#  terraform {
#   backend "s3" {
#     bucket = "whiskey-log-bucket-noabm"
#     key    = "~/AWS-and-Terraform/VPC-assignment2/terraform.tfstate"
#     region = "us-east-1"
#   }
# }
data "aws_vpc" "main" {
  id = aws_vpc.main.id
}