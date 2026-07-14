variable "env" {}
variable "vpc_cidr" {}
variable "public_cidrs" { type = list(string) }
variable "private_app_cidrs" { type = list(string) }
variable "private_data_cidrs" { type = list(string) }
variable "azs" { type = list(string) }
