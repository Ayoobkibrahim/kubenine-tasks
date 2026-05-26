############################################
# VPC OUTPUTS
############################################

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

############################################
# SECURITY GROUP OUTPUTS
############################################

output "security_group_id" {
  value = module.web_sg.security_group_id
}

############################################
# EC2 OUTPUTS
############################################

output "ec2_instance_id" {
  value = module.ec2_instance.id
}

output "ec2_public_ip" {
  value = module.ec2_instance.public_ip
}

############################################
# ALB OUTPUTS
############################################

output "alb_dns_name" {
  value = module.alb.dns_name
}

output "alb_arn" {
  value = module.alb.arn
}

############################################
# TARGET GROUP OUTPUTS
############################################

output "target_group_arn" {
  value = module.alb.target_groups["web"].arn
}