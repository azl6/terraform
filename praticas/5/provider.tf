terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.54.0"
    }
  }

  backend "s3" {
    bucket = "s3-terraform-backend-azl6" 
    key    = "terraform.tfstate"       
    region = "sa-east-1"  
    dynamodb_table = "terraform_state_lock"
  }
}

provider "aws" {
    region = "sa-east-1"
}