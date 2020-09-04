data "aws_ami" "amznlinux2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"] # Amazon
}

resource "aws_spot_instance_request" "bastion" {
  #for_each                = data.aws_subnet_ids.public.ids  
  wait_for_fulfillment    = true
  instance_type           = "t2.micro"
  ami                     = data.aws_ami.amznlinux2.id
  key_name                = aws_key_pair.auth.id
  vpc_security_group_ids  = [module.bastion_sg.this_security_group_id]
  subnet_id               = module.vpc.public_subnets[0]
  root_block_device {
    delete_on_termination = true
    volume_type           = "standard"
  }
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=demo1-bastion --region ${var.aws_region}"
  }
  tags = {
    Name        = "${var.app_prefix}-bastion"
    Terraform   = "true"
    Environment = var.env
  }
}

#Traffic mirroring requires Nitro-based instance
resource "aws_spot_instance_request" "mirror-src" {
  #for_each                = data.aws_subnet_ids.private.ids  
  wait_for_fulfillment    = true
  instance_type           = "t3.medium"
  ami                     = data.aws_ami.amznlinux2.id
  key_name                = aws_key_pair.auth.id
  vpc_security_group_ids  = [module.internal_sg.this_security_group_id]
  subnet_id               = module.vpc.private_subnets[0]
  user_data               = file("cloud-init1.sh")
  root_block_device {
    delete_on_termination = true
    volume_type           = "standard"
  }
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=demo1-mirror-src --region ${var.aws_region}"
  }
  tags = {
    Name        = "${var.app_prefix}-mirror-src"
    Terraform   = "true"
    Environment = var.env
  }
}

#Traffic mirroring requires Nitro-based instance
resource "aws_spot_instance_request" "mirror-target" {
  #for_each                = data.aws_subnet_ids.private.ids  
  wait_for_fulfillment    = true
  instance_type           = "t3.medium"
  ami                     = data.aws_ami.amznlinux2.id
  key_name                = aws_key_pair.auth.id
  vpc_security_group_ids  = [module.internal_sg.this_security_group_id]
  subnet_id               = module.vpc.private_subnets[0]
  user_data               = file("cloud-init2.sh")
  root_block_device {
    delete_on_termination = true
    volume_type           = "standard"
  }
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=demo1-mirror-target --region ${var.aws_region}"
  }
  tags = {
    Name        = "${var.app_prefix}-mirror-src"
    Terraform   = "true"
    Environment = var.env
  }
}

# Traffic Mirroring
resource "aws_ec2_traffic_mirror_target" "nlb" {
  description               = "${var.app_prefix}-NLB target"
  network_load_balancer_arn = aws_lb.target.arn
}

resource "aws_ec2_traffic_mirror_session" "session" {
  description              = "${var.app_prefix}- traffic mirror session"
  session_number           = 1
  virtual_network_id       = 1111
  network_interface_id     = aws_spot_instance_request.mirror-src.primary_network_interface_id
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.filter.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.nlb.id
}

resource "aws_ec2_traffic_mirror_filter" "filter" {
  description      = "${var.app_prefix} - traffic mirror filter"
}

# resource "aws_ec2_traffic_mirror_filter_rule" "ruleout" {
#   description              = "${var.app_prefix} rule"
#   traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.filter.id
#   destination_cidr_block   = "10.0.0.0/8"
#   source_cidr_block        = "10.0.0.0/8"
#   rule_number              = 1
#   rule_action              = "accept"
#   traffic_direction        = "egress"
# }

resource "aws_ec2_traffic_mirror_filter_rule" "rulein" {
  description              = "test rule"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.filter.id
  destination_cidr_block   = module.vpc.vpc_cidr_block
  source_cidr_block        = module.vpc.vpc_cidr_block
  rule_number              = 1
  rule_action              = "accept"
  traffic_direction        = "ingress"
  protocol                 = 6

  destination_port_range {
    from_port = 8888
    to_port   = 8888
  }

}