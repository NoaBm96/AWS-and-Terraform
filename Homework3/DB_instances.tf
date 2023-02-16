### DB instances ###
resource "aws_instance" "db_server" {
    count                  = var.DB_instances_count
    ami                    = data.aws_ami.ubuntu.id
    key_name               = var.key_name
    instance_type          = var.instance_type
    vpc_security_group_ids = [aws_security_group.DB_instnaces_access.id]
    subnet_id              = module.vpc_module.private_subnets_id[count.index]
    associate_public_ip_address = false
    tags = {  
      "Name" = "DB-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    }
}

### security group for DB
resource "aws_security_group" "DB_instnaces_access" {
  vpc_id = module.vpc_module.vpc_id
  name   = "DB-access"
  tags = {
    "Name" = "DB-access-${module.vpc_module.vpc_id}"
  }
}

resource "aws_security_group_rule" "DB_ssh_acess" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.DB_instnaces_access.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "DB_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.DB_instnaces_access.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}