# firewall ingress/egress rules for our instaces, use default one that created by aws
# ssh port 22 for connection with our instances through only your ip & port 8080 for accessing your nginx applicatopn through browser
resource "aws_default_security_group" "default-security-group" {
  vpc_id      = var.vpc_id

  # one ingress rule for each port
  ingress {
    description      = "SSH Conn"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip_add]
  }
  ingress {
    description      = "Nginx Conn"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # for allowing access to VPC endpoints
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-default-sg"
  }
}

# you need to specify the ami for your ec2 instance , and we will fetch it from aws 
data "aws_ami" "latest-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.image_name]
    //values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] 
}

# we need to specify the keypair that allows us ssh into the instance
resource "aws_key_pair" "ssh-keygen" {
  key_name   = "deployer-key"
  public_key = file(var.public_key_location)
}

# for any ec2 you need to specify : 1- ami 1- instance type  3- subnet   4- availability zone    5- security group   6- keypair for accessing our ec2 instance     7- puplic ip for your instance   8- user_data for running your script on your ec2 instance while creation
resource "aws_instance" "web-instance" {
  ami           = data.aws_ami.latest-ami.id
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.default-security-group.id]
  availability_zone = var.avail_zone  

  # we need a puplic ip for our instance , as we want be able to to access this ec2 instance from browser.
  associate_public_ip_address = true
  # we need to specify the keypair that allows us ssh into the instance
  key_name = aws_key_pair.ssh-keygen.key_name

  # passing a data to AWS: execute set of commands on ec2 instance at the time of creation , Using user_data that act as an entrypoint script that get executed on creation of ec2 
  user_data = file("entry-script.sh")

  tags = {
    Name = "${var.env_prefix}-server"
  }
}