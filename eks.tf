# Configure the AWS Provider
provider "aws" {
    region = "eu-central-1"
}


resource "aws_vpc" "myapp-vpc" {
  # ip range inside vpc  
  cidr_block  = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# use the subnet module by referencing it form another config file
module "myapp-subnet" {
  source  = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

# you have to associate the subnet with your routetable so the traffic inside the subnet can handled by routetable 
# but if you use the default routetable then your subnet is attached with your main route table by default , so you don't have to use this block
/*
resource "aws_route_table_association" "default-subnet-rtb" {
  subnet_id      = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_default_route_table.default-rtb.id
}
*/

# use the webserver module by referencing it form another config file
module "myapp-webserver" {
  source  = "./modules/webserver"
  vpc_id = aws_vpc.myapp-vpc.id
  my_ip_add = var.my_ip_add
  env_prefix = var.env_prefix
  image_name = var.image_name
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  avail_zone = var.avail_zone
  subnet_id = module.myapp-subnet.subnet.id
}
