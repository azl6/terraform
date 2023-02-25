resource "aws_key_pair" "ssh" {
  key_name   = "TF-KEY"
  public_key = file("/home/azl6/.ssh/id_rsa.pub")
}