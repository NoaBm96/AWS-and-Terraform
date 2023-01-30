### EC2 Instance ###
resource "aws_instance" "aws_ubuntu" {
    count = 2
    ami = data.aws_ami.ubuntu.id
    key_name    = var.key_name
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
    subnet_id = aws_subnet.public_subnets.*.id[count.index]
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
    user_data = <<-EOF
    #! /bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx
    sudo systemtl start nginx
    sudo systemtl enable nginx
    echo "<h1>Welcome to Grandpas Whiskey</h1>" | sudo tee /var/www/html/index.html
    EOF
}

### DB instances ###
resource "aws_instance" "db_server" {
    count = 2
    ami = data.aws_ami.ubuntu.id
    key_name    = var.key_name
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.db_server.id]
    subnet_id = aws_subnet.private_subnets.*.id[count.index]
    tags = {  
        owner = "Grandpa"
        server_name = "db${count.index}"
        purpose = "db_server"
    }
    user_data = <<-EOF
    #! /bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx
    sudo systemtl start nginx
    sudo systemtl enable nginx
    echo "<h1>DB server</h1>" | sudo tee /var/www/html/index.html
    EOF
}