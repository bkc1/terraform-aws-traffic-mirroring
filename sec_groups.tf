
module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bastion-sg"
  description = "Security group for bastion/jump-host"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["ssh-tcp"]
  egress_cidr_blocks       = ["0.0.0.0/0"]
  egress_rules             = ["all-all"]
}

module "internal_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "internal-sg"
  description = "Security group for internal hosts"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["10.0.0.0/16", ]
  ingress_rules            = ["ssh-tcp", "all-icmp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8888
      to_port     = 8888
      protocol    = "tcp"
      description = "test port"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 4789
      to_port     = 4789
      protocol    = "udp"
      description = "traffic mirrot port"
      cidr_blocks = "10.0.0.0/16"
    },
  ]
  egress_cidr_blocks       = ["0.0.0.0/0"]
  egress_rules             = ["all-all"]
}