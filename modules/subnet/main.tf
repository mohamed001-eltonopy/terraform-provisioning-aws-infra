resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone  
  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}

# specify igw for accessing internet and each vpc have one igw 
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# use l default route table that created by aws and act as a virtual router inside your vpc for handling all the traffic that coming and leaving in the internet and handling the traffic inside vpc
resource "aws_default_route_table" "default-rtb" {
  default_route_table_id = var.default_route_table_id

  route {
    # route table handling the traffic inside vpc by default once you attached this route table to your vpc ,so you don't have to specify the route inside vpc
    # handling the traffic to/from the internet through Internet gateway
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}
 