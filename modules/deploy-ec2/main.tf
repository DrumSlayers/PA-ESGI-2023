# EC2

# Virtual Private Cloud

# Create VPC 
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = var.vpc_instance_tenancy
  enable_dns_hostnames = true
}

# Create VPC subnet 
resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.vpc_subnet_cidr_block
}

# Create VPC internet gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id            = aws_vpc.vpc.id
}

# Create routes for VPC from Internet to subnet
resource "aws_route_table" "public-route-table" {
  vpc_id            = aws_vpc.vpc.id

  route {
    gateway_id = aws_internet_gateway.internet-gateway.id
    cidr_block = "0.0.0.0/0"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.internet-gateway.id
  }
}

resource "aws_route_table_association" "public-rt-to-subnet" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_security_group" "public-sg" {

  #description = "security group to allow incoming SSH connection to ec2 instance"
  name = var.sg_name
  vpc_id = aws_vpc.vpc.id

  ingress = [{
    cidr_blocks      = var.cidr_blocks_ingress
    description      = "Allow SSH"
    from_port        = var.from_port_ingress
    ipv6_cidr_blocks = var.ipv6_cidr_blocks_ingress
    prefix_list_ids  = var.prefix_list_ids_ingress
    protocol         = var.protocol_ingress
    security_groups  = var.security_groups_ingress
    self             = var.self_ingress
    to_port          = var.to_port_ingress
  }]

  egress = [{
    description      = "Allow connection to any internet service"
    from_port        = var.from_port_egress
    to_port          = var.to_port_egress
    protocol         = var.sg_egress_protocol
    cidr_blocks      = var.cidr_blocks_egress
    self             = var.self_egress
    ipv6_cidr_blocks = var.ipv6_cidr_blocks_egress
    prefix_list_ids  = var.prefix_list_ids_egress
    security_groups  = var.security_groups_egress

  }]

}

# EC2 3CX Deploy

resource "aws_key_pair" "ssh-key" {

  key_name   = var.ssh_key_name
  public_key = var.public_ssh_key
}

resource "aws_instance" "myec2" {
  ami                         = var.ami_id
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.ssh-key.key_name
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.public-sg.id]
  associate_public_ip_address = true
  user_data = <<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install awscli -y
sudo apt-get install s3fs -y
sudo apt-get install pydf -y

aws configure set aws_access_key_id_id  ${var.aws_access_key_id}
aws configure set aws_secret_access_key ${var.aws_secret_access_key}
aws configure set aws_session_token ${var.aws_session_token}
aws configure set default.region ${var.aws_region}

# simple user
user = $(whoami)

sudo mkdir -p ${var.mount_point}
sudo chown -R $user:$user ${var.mount_point}

s3fs ${var.bucket_name} ${var.mount_point} -o profile=default -o nonempty,rw,allow_other,mp_umask=002,uid=1000,gid=1000  -o url=http://s3.us-east-1.amazonaws.com/
sudo echo ${var.bucket_name} ${var.mount_point} fuse.s3fs _netdev,allow_other 0 0 >> /etc/fstab
EOF
  tags = {
    "Name" = var.ec2_name
  }

}