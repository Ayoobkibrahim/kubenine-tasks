output "alb_dns" {
  value = module.alb.dns_name
}

output "ec2_private_ips" {
  value = [module.ec2_1.private_ip, module.ec2_2.private_ip]
}

output "vpc_id" {
  value = module.vpc.vpc_id
}