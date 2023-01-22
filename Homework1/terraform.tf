provider "aws" {
     region = var.region
     profile = "noa-admin"
 }
resource "aws_default_vpc" "default" {

}
resource "aws_security_group" "allow_ssh" {
  name        = "nginx_sg"
  description = "allow http on port 80"
  vpc_id      = aws_default_vpc.default.id

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
resource "aws_instance" "aws_ubuntu" {
    count = 2
    ami = "ami-00874d747dde814fa"
    instance_type = "t3.micro"
    tags = {  
        owner = "Grandpa"
        server_name = "nginx${count.index}"
        purpose = "Whiskey_web"
    }
    key_name    = var.key_name
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]

    root_block_device{

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

    provisioner "remote-exec" {
        inline = [
            "sudo apt update -y",
            "sudo apt install nginx -y",
            "echo 'Welcome to Grandpas Whiskey' | sudo tee /var/www/html/index.html",
            "sudo service nginx restart"
        ]
    }
}

