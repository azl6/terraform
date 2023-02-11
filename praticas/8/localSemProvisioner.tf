locals {
  array = ["alex", "bruna", "marcelo"]
}

output "nome" {
  value = local.array[1]
}