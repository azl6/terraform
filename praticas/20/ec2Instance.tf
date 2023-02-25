module "myEc2RootModule" {
    source = "./MOD-EC2"
    instance_type = "t2.large"

}

output "InstanceTypeOutput" {
  value = module.myEc2RootModule.InstanceTypeOutput
}