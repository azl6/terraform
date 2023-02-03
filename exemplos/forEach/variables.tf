variable "ec2Tags" {

  type = map

  default = {

    tag1 = {
      "nome" = "EC2-DEV",
      "environment" = "DEVELOPMENT"
    },
    tag2 = {
      "nome" = "EC2-PROD",
      "environment" = "PRODUCTION"
    }

  }
}