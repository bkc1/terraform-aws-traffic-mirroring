module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.app_prefix
  cidr = var.vpc_cidr_block

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform = "true"
    Environment = var.env
  }
}