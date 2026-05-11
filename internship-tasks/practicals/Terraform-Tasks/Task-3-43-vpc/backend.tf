terraform {
  backend "s3" {
    bucket         = "task-3-41-tf-state-aki"
    key            = "task-3-43-vpc/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "task-3-41-tf-lock"
  }
}