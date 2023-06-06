# EC2

# SSH Keys
resource "aws_key_pair" "ssh-keys" {
  count      = length(var.ssh_public_keys)
  key_name   = "ssh-keys_${count.index}"
  public_key = element(var.ssh_public_keys, count.index)
}

# Virtual Private Cloud

# - Create VPC 
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = var.vpc_instance_tenancy
  enable_dns_hostnames = true
}

# - Create VPC subnet 
resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.vpc_subnet_cidr_block
}

# - Create VPC internet gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id            = aws_vpc.vpc.id
}

# - Create routes for VPC from Internet to subnet
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


# EC2 
locals {
  vars = {
    scaleway_access_key = var.scaleway_access_key
    scaleway_secret_key = var.scaleway_secret_key
    ssh_public_keys     = var.ssh_public_keys
  }
}

## Dolibarr
resource "aws_instance" "ec2-dolibarr" {
  ami                         = var.ami_id
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.ssh-keys[0].key_name
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.public-sg.id]
  user_data_replace_on_change = true                                # Destroy & Recreate on user_data change
  associate_public_ip_address = true
  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = var.ec2_volume_type
  }
  user_data = base64encode(templatefile("${path.module}/deploy-scripts/dolibarr.tftpl", local.vars))
  tags = {
    "Name" = var.ec2_name
  }

}

## Nextcloud  
resource "aws_instance" "ec2-nextcloud" {
  ami                         = var.ami_id
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.ssh-keys[0].key_name
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.public-sg.id]
  user_data_replace_on_change = true                                # Destroy & Recreate on user_data change
  associate_public_ip_address = true
  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = var.ec2_volume_type
  }
  user_data = base64encode(templatefile("${path.module}/deploy-scripts/nextcloud.tftpl", local.vars))
  tags = {
    "Name" = var.ec2_name_storage
  }

}
# EC2 DNS Entries
resource "cloudflare_record" "cname-dolibarr" {
  zone_id = var.cloudflare_zone_id
  name    = "crm.transexpress.ovh"
  value   = "${aws_instance.ec2-dolibarr.public_dns}"
  type    = "CNAME"
  ttl     = 120
  proxied = false
}

resource "cloudflare_record" "cname-nextcloud" {
  zone_id = var.cloudflare_zone_id
  name    = "cloud.transexpress.ovh"
  value   = "${aws_instance.ec2-nextcloud.public_dns}"
  type    = "CNAME"
  ttl     = 120
  proxied = false
}