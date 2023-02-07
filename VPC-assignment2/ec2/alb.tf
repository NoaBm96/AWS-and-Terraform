### application load balancer ###
resource "aws_alb" "public_alb" {
  name               = "whiskey-alb"
  internal = false
  subnets = aws_subnet.public_subnets[*].id
  security_groups = [aws_security_group.allow_all.id]
  tags = {
    Name = "Whiskey-servers-elb"
  }
}

resource "aws_alb_listener" "public_lis" {
  load_balancer_arn = aws_alb.public_alb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.web.id
  }
}

resource "aws_alb_target_group" "web" {
    name = "alb-tg"
    port = "80"
    protocol = "HTTP"
    vpc_id = data.aws_vpc.main.id
    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        path              = "/"
        interval            = 5
    } 
    stickiness {
    type = "app_cookie"
    enabled = true
    cookie_duration = 60
    }
}

resource "aws_alb_target_group_attachment" "tg_attachment" {
    count = length(aws_instance.web_instances.*.id)
    target_group_arn = aws_alb_target_group.web.arn
    target_id = aws_instance.web_instances[count.index].id 
}

output "alb_dns_name" {
    value = aws_alb.public_alb.dns_name
}
