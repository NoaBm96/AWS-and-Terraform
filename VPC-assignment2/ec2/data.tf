data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
    }
}
data "aws_vpc" "main" {
  id = aws_vpc.main.id
}
vpc_id     = module.vpc.vpc_id
