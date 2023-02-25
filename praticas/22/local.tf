locals {
  hw = "Hello World!"
}

output "printLocal" {
  value = local.hw
}