output "bastion_public_dns"        { value = "${aws_spot_instance_request.bastion.public_dns}"}
output "ec2_src_private_ip"        { value = "${aws_spot_instance_request.mirror-src.private_ip }"}
output "ec2_target_private_ip"     { value = "${aws_spot_instance_request.mirror-target.private_ip }"}
output "src_nlb_private_ip"        { value = "${aws_lb.src.dns_name}"}
output "target_nlb_private_ip"     { value = "${aws_lb.target.dns_name}"}