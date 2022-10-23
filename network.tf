module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = "uu-vpc"
    cidr = "192.168.0.0/16"
    azs = ["ap-south-1a", "ap-south-2a"]
    private_subnets = ["192.168.0.0/24", "192.168.1.0/24"]
    public_subnets = ["192.168.2.0/24", "192.168.3.0/24"]

    enable_nat_gateway = false 
    enable_vpn_gateway = false

    tags = {
        Terraform = "true"
        Environment = "dev"
  }  
}