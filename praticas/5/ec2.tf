resource "aws_instance" "MyEC2" {
   ami = "ami-0b0d54b52c62864d6"
   instance_type = "t2.micro"
   count = var.shouldLaunch == true ? 1 : 0

   tags = {
    "Name" = lookup(var.ec2NameTag, terraform.workspace)
    "ENVIRONMENT" = lookup(var.tags, terraform.workspace)
   }
}