variable "instanceTypes" {
    type = map
    default = {
        dev = "t2.micro",
        prod = "t2.large"
    }
}