variable "region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "my_ip" {
  description = "IP for SSH"
}

variable "public_key_path" {
  description = "Path to SSH public key"
}