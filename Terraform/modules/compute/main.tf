# External Application Load Balancer
resource "aws_lb" "external_alb" {
  name               = "${var.env}-external-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

}

#Web Tier Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.env}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# Listener for Application Load Balancer
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

## Route 53 Setup

#Gathering data from the AWS
data "aws_route53_zone" "primary" {
  name = var.domain_name
}

# Route 53 Record for "www"
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  alias {
    name                   = var.web_cdn_domain_name
    zone_id                = var.web_cdn_hosted_zone_id
    evaluate_target_health = true
  }
}

# Web Auto Scaling Group
resource "aws_launch_template" "web" {
  name_prefix            = "${var.env}-web-"
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [var.web_sg_id]
}

resource "aws_autoscaling_group" "web_asg" {
  vpc_zone_identifier = var.public_subnet_ids
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.web_tg.arn]
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
}

# Backend Auto Scaling Group
resource "aws_launch_template" "backend" {
  name_prefix            = "${var.env}-backend-"
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [var.backend_sg_id]

}

resource "aws_autoscaling_group" "backend_asg" {
  vpc_zone_identifier = var.private_subnet_ids
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
}




