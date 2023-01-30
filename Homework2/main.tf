provider "aws" {
     region = var.region
     profile = "noa-admin"
}

data "aws_availability_zones" "available"{
  state = "available"
}

### VPC ###
resource "aws_vpc" "main" {
 cidr_block = var.vpc_cidr
 tags = {
   Name = "Whiskey - VPC"
 }
}

### 2 Public Subnet ###
resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs) #create subnet as the amount of cidrs
 vpc_id     = aws_vpc.main.id
 cidr_block = var.public_subnet_cidrs[count.index]
 map_public_ip_on_launch = true #auto assign IP
 availability_zone = element(data.aws_availability_zones.available.names[*], count.index) #create each subnet in az from the all available az's list
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}

### 2 Private subnet ###
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = var.private_subnet_cidrs[count.index]
 availability_zone = element(data.aws_availability_zones.available.names[*], count.index)
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

### Internet gateway ###
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 tags = {
   Name = "Whiskey VPC IG"
 }
}

### elastic IP ###
resource "aws_eip" "elasticip" {
  vpc      = true
}

### NAT gateway ###
resource "aws_nat_gateway" "private_nat" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name = "whiskey gw NAT"
  }
}

### public route table ###
resource "aws_route_table" "public_rt" {
 vpc_id = aws_vpc.main.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 tags = {
   Name = "Public Route Table"
   Description = "allows outbound traffic for the internet"

 }
}

### public route table association ###
resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.public_rt.id
}

### private route table ###
resource "aws_route_table" "private_rt" {
 vpc_id = aws_vpc.main.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_nat_gateway.private_nat.id
 }
 tags = {
   Name = "Private Route Table"
   Description = "NAT gateway for private networks"
 }
}

### private route table association ###
resource "aws_route_table_association" "private_subnet_asso" {
 count = length(var.private_subnet_cidrs)
 subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
 route_table_id = aws_route_table.private_rt.id
}

### security group ###
resource "aws_security_group" "allow_ssh" {
  name        = "nginx_sg"
  description = "allow http on port 80"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

### security group for DB ###
resource "aws_security_group" "db_server" {
  name        = "db_sg"
  vpc_id      = aws_vpc.main.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

### classic load balancer ###
resource "aws_elb" "elb" {
  name               = "whiskey-lb"
  subnets = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
  security_groups = [aws_security_group.allow_ssh.id]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
   listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  instances                   = [aws_instance.aws_ubuntu[0].id, aws_instance.aws_ubuntu[1].id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "Whiskey-servers-elb"
  }
}

