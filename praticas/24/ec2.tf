resource "aws_instance" "CUSTOMEC2NAME" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = var.instance_type

  tags = {
    "Name" = "customNameForMyEc2"
  }
}