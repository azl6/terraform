module "securityGroup" {
  source = "./securityGroupModule"
}

resource "aws_instance" "MyEC2" {
  ami             = "ami-0b0d54b52c62864d6"
  instance_type   = lookup(var.instanceType, terraform.workspace)
  security_groups = [module.securityGroup.securityGroupName]

  tags = {
    "Name" = "Terraform"
  }

}