variable "env" {}

variable "vpc_id" {}

variable "public_subnet_ids" {}

variable "private_subnet_ids" {}
variable "alb_sg_id" {}
variable "web_sg_id" {}
variable "backend_sg_id" {}
variable "domain_name" {}

variable "web_cdn_hosted_zone_id" {}
variable "web_cdn_domain_name" {}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

}
