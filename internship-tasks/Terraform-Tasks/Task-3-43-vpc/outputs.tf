output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "nat_gateway_id" {
  value = module.vpc.natgw_ids
}

output "public_nacl_id" {
  value = module.vpc.public_network_acl_id
}