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
sudo apt-get install python3-pip -y
  pip3 install awscli_plugin_endpoint

aws configure set plugins.endpoint awscli_plugin_endpoint

cat << HEL >> ~/.aws/config
[plugins]
endpoint = awscli_plugin_endpoint
[default]
region = fr-par
s3 =
  endpoint_url = https://s3.fr-par.scw.cloud
s3api =
  endpoint_url = https://s3.fr-par.scw.cloud
HEL

aws configure set aws_access_key_id ${var.aws_access_key_id}
aws configure set aws_secret_access_key ${var.aws_secret_access_key}

EOF
  tags = {
    "Name" = var.ec2_name
  }

}