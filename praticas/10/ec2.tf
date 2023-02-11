resource "aws_instance" "MyEC2" {
    ami = "AMI_DA_REGIÃO_DO_ALIAS"
    instance_type = "t2.micro"
    provider = "CHOSEN_PROVIDER_NAME"
}