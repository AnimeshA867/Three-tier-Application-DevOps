provider "aws" {
  region = var.aws_region

}

module "vpc" {
  source             = "./modules/vpc"
  env                = var.env
  vpc_cidr           = var.vpc_cidr
  public_cidrs       = var.public_cidrs
  private_app_cidrs  = var.private_app_cidrs
  private_data_cidrs = var.private_data_cidrs
  azs                = var.azs
}

module "security_groups" {
  source = "./modules/security_groups"
  env    = var.env
  vpc_id = module.vpc.vpc_id
}

module "compute" {
  source = "./modules/compute"
  env    = var.env
  vpc_id = module.vpc.vpc_id

  public_subnet_ids = module.vpc.public_subnet_ids

  private_subnet_ids     = module.vpc.private_app_subnet_ids
  alb_sg_id              = module.security_groups.alb_sg_id
  web_sg_id              = module.security_groups.web_sg_id
  backend_sg_id          = module.security_groups.backend_sg_id
  domain_name            = var.domain_name
  web_cdn_domain_name    = module.cloudfront.web_cdn_domain_name
  web_cdn_hosted_zone_id = module.cloudfront.web_cdn_zone_id
}

module "data" {
  source          = "./modules/data"
  env             = var.env
  data_subnet_ids = module.vpc.private_data_subnet_ids
  rds_sg_id       = module.security_groups.rds_sg_id
  redis_sg_id     = module.security_groups.redis_sg_id
}

module "cloudfront" {
  source       = "./modules/cloudfront"
  env          = var.env
  alb_dns_name = module.compute.alb_dns_name
}
