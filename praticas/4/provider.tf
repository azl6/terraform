terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.53.0"
    }
  }

  backend "s3" { #########################
    bucket = "s3-terraform-backend-azl6" # Configurações
    key    = "4/terraform.tfstate"       # backend
    region = "sa-east-1"                 #
  }
}

provider "aws" {
  region = "sa-east-1"
}