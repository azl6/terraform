variable "instanceType" {
  type = map(any)
  default = {
    "dev"  = "t2.micro"
    "prod" = "t2.small"
  }
}