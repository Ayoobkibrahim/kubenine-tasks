# Backend configuration
terraform {
  backend "s3" {
    bucket         = "task-3-41-tf-state-aki"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "task-3-41-tf-lock"
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "task-3-41-test-bucket" {
  bucket = var.bucket_name

  tags = {
    Name = "task-3-41-test-bucket"
    Environment = "stage"
    Task = "3-41"
  }
}