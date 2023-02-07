### VPC ###
resource "aws_vpc" "main" {
 cidr_block = var.vpc_cidr
 tags = {
   Name = "Whiskey - VPC"
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
resource "aws_eip" "nat_eip" {
  vpc      = true
  tags = {
   Name = "Elastic IP for whiskey"
 }
}

### NAT gateway ###
resource "aws_nat_gateway" "private_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name = "whiskey gw NAT"
  }
}

data "aws_availability_zones" "available"{
  state = "available"
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
