

resource "aws_lb" "src" {  
  name               = "${var.app_prefix}-mirror-src"
  internal           = true
  load_balancer_type = "network"
  subnets            = [module.vpc.private_subnets[0]]
  tags = {
    Terraform = "true"
    Environment = var.env
  }
}

resource "aws_lb" "target" {
  name               = "${var.app_prefix}-mirror-target"
  internal           = true
  load_balancer_type = "network"
  subnets            = [module.vpc.private_subnets[0]]
  tags = {
    Terraform = "true"
    Environment = var.env
  }
}

resource "aws_lb_listener" "src" {
  load_balancer_arn = aws_lb.src.arn
  port              = "8888"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.src.arn
  }
}

resource "aws_lb_listener" "target" {
  load_balancer_arn = aws_lb.target.arn
  port              = "4789"
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }
}

resource "aws_lb_target_group" "src" {
  target_type = "instance"  
  name        = "${var.app_prefix}-lb-tg-src"
  port        = 8888
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  health_check {
    enabled  = true  
    port     = 8888
    protocol = "TCP"    
  }
}

# port 8888 is an arbitrary health-check needed to pass traffic since UDP healthchecks are not currently supported.
resource "aws_lb_target_group" "target" {
  target_type = "instance"  
  name        = "${var.app_prefix}-lb-tg-target"
  port        = 4789
  protocol    = "UDP"
  vpc_id      = module.vpc.vpc_id
  health_check {
    enabled  = true  
    port     = 8888
    protocol = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "src" {
  target_group_arn = aws_lb_target_group.src.arn
  target_id        = aws_spot_instance_request.mirror-src.spot_instance_id
  port             = 8888
}

resource "aws_lb_target_group_attachment" "target" {
  target_group_arn = aws_lb_target_group.target.arn
  target_id        = aws_spot_instance_request.mirror-target.spot_instance_id
  port             = 4789
}