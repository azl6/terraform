terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.54.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
  alias = "br1" 
}

provider "aws" {
  region = "us-west-1"
  alias = "us1"
}

provider "aws" {
  region = "us-east-1"
  alias = "us2"
}