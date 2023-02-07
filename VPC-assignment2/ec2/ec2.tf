resource "aws_instance" "web_instances" {
    count = 2
    ami = data.aws_ami.ubuntu.id
    key_name    = var.key_name
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.instances.id]
    subnet_id = aws_subnet.private_subnets.*.id[count.index]
    iam_instance_profile = aws_iam_instance_profile.web_server.name
    tags = {  
        owner = "Grandpa"
        server_name = "nginx${count.index}"
        purpose = "Whiskey_web"
    }
    volume_tags = {  
        owner = "Grandpa"
        server_name = "nginx-${count.index}"
        purpose = "Whiskey_web"
    }

    ebs_block_device{
        device_name = "/dev/xvdba"
        volume_size = "10"
        volume_type = "gp2"
        encrypted = true
    }

    connection {
        type = "ssh"
        host = self.public_ip
        user = "ubuntu"
        private_key = file(var.private_key_path)

    }
    user_data = file("./nginx.sh")
}

### DB instances ###
resource "aws_instance" "db_server" {
    count = 2
    ami = data.aws_ami.ubuntu.id
    key_name    = var.key_name
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.instances.id]
    subnet_id = aws_subnet.private_subnets.*.id[count.index]
    tags = {  
        owner = "Grandpa"
        server_name = "db${count.index}"
        purpose = "db_server"
    }
}

### security group for load balancer ###
resource "aws_security_group" "allow_all" {
  name        = "allow-all"
  vpc_id      = "${aws_vpc.main.id}"
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

### security group for instances ###
resource "aws_security_group" "instances" {
  name        = "instances_sg"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups = [aws_security_group.allow_all.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

