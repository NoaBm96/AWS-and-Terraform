module "vpc" {
    source = "./VPC-assignment2/vpc/"
}
module "ec2" {
    source = "./VPC-assignment2/ec2/"
    vpc_id     = module.vpc.vpc_id
}