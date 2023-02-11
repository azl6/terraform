resource "aws_key_pair" "deployer" {
  key_name   = "azl6-key"
  public_key = file("/home/azl6/.ssh/id_rsa.pub")
}