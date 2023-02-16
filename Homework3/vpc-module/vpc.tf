### VPC ###
resource "aws_vpc" "main" {
 cidr_block = var.vpc_cidr
 tags = {
   Name = "Whiskey - VPC"
 }
}

### Internet gateway ###
resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.main.id
 tags = {
   Name = "IGW_${aws_vpc.main.id}"
 }
}

### elastic IP ###
resource "aws_eip" "nat_eip" {
  count = length(var.public_subnet_cidrs)
  vpc      = true
  tags = {
   Name = "NAT_EIP_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.main.id}"
 }
}

### NAT gateway ###
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat_eip.*.id[count.index]
  subnet_id     = aws_subnet.public_subnets.*.id[count.index]
  tags = {
    Name = "NAT_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.main.id}"
  }
}

### 2 Public Subnet ###
resource "aws_subnet" "public_subnets" {
 map_public_ip_on_launch = "true" #auto assign IP
 count      = length(var.public_subnet_cidrs) #create subnet as the amount of cidrs
 vpc_id     = aws_vpc.main.id
 cidr_block = var.public_subnet_cidrs[count.index]
 availability_zone = data.aws_availability_zones.available.names[count.index] #create each subnet in az from the all available az's list
 tags = {
   Name = "Public_subnet_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.main.id}"
 }
}

### 2 Private subnet ###
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = var.private_subnet_cidrs[count.index]
 map_public_ip_on_launch = "false"
 availability_zone = data.aws_availability_zones.available.names[count.index]
 tags = {
   Name = "Private_subnet_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.main.id}"
 }
}

### route table ###
resource "aws_route_table" "route_tables" {
  count = length(var.route_tables_name_list)
  vpc_id    = aws_vpc.main.id
#   tags = {
#    Name = "${var.route_tables_name_list}_RTB_${aws_vpc.main.id}"
#  }
}

### public route table association ###
resource "aws_route_table_association" "public" {
 count          = length(var.public_subnet_cidrs)
 subnet_id      = aws_subnet.public_subnets.*.id[count.index]
 route_table_id = aws_route_table.route_tables[0].id
}

### private route table association ###
resource "aws_route_table_association" "private" {
 count          = length(var.private_subnet_cidrs)
 subnet_id      = aws_subnet.private_subnets.*.id[count.index]
 route_table_id = aws_route_table.route_tables[count.index + 1].id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.route_tables[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_route" {
  count = length(var.private_subnet_cidrs)
  route_table_id         = aws_route_table.route_tables.*.id[count.index + 1]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.*.id[count.index]
}