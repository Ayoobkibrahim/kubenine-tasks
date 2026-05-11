terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket         = "task-3-41-tf-state-aki"
    key            = "task-3-47-ecs/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "task-3-41-tf-lock"
  }
}