variable "shouldLaunch" {
    type = bool
    default = true
}

variable "ec2NameTag" {
    type = map
    default = {
        "dev" = "EC2-DEVELOPMENT",
        "prod" = "EC2-PRODUCTION"
    }
}

variable "tags" {
    type = map
    default = {
        "dev" = "EC2-DEVELOPMENT",
        "prod" = "EC2-PRODUCTION"
    }
}