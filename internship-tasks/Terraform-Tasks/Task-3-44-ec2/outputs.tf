output "instance_id" {
  value = module.ec2.id
}

output "public_ip" {
  value = module.ec2.public_ip
}

output "url" {
  value = "http://${module.ec2.public_ip}"
}

output "security_group_id" {
  value = aws_security_group.task-3-44-nginx-sg.id
}