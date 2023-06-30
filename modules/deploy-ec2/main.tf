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

resource "aws_security_group" "ec2_sg" {
  for_each = var.ec2-config
  name = "${each.key}-sg"
  description = "The security group of ${each.key} EC2"
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Server" = "${each.key}"
    "Provider" = "Terraform"
  }

  dynamic "ingress" {
    for_each = each.value.ports[*]
    content {
      from_port   =  ingress.value.from
      to_port     =  ingress.value.to
      protocol    = "tcp"
      cidr_blocks = ingress.value.source != "::/0" ? [ingress.value.source] : null
      ipv6_cidr_blocks = ingress.value.source =="::/0" ? [ingress.value.source] : null
      security_groups = null 
    }
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    } 
}

# EC2 
locals {
  vars = {
    scaleway_access_key = var.scaleway_access_key
    scaleway_secret_key = var.scaleway_secret_key
    ssh_public_keys     = var.ssh_public_keys
    mysql_host          = var.mysql_host
    mysql_user          = var.mysql_user
    mysql_password      = var.mysql_password
    mysql_database      = var.mysql_database
    redis_host          = var.redis_host
    redis_port          = var.redis_port
    redis_password      = var.redis_password
    acme_email          = var.acme_email
    acme_storage        = var.acme_storage
    s3_bucket           = var.s3_bucket
    s3_region           = var.s3_region
    s3_hostname         = var.s3_hostname
    s3_key              = var.s3_key
    s3_secret           = var.s3_secret
    s3_port             = var.s3_port
    trusted_domain      = var.trusted_domain
    trusted_proxy       = var.trusted_proxy
    

  }
}

resource "aws_instance" "vm" {
  for_each                    = var.ec2-config
  ami                         = each.value.ami_id
  instance_type               = each.value.instance_type
  key_name                    = aws_key_pair.ssh-keys[0].key_name
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg[each.key].id]
  user_data_replace_on_change = true                                # Destroy & Recreate on user_data change
  associate_public_ip_address = true
  root_block_device {
    volume_size = each.value.volume_size
    volume_type = each.value.volume_type
  }
  user_data = base64encode(templatefile("${path.module}/deploy-scripts/${each.key}.tftpl", local.vars))
  tags = {
    "Name" = each.key
    "DNS" = each.value.dns_name
  }
}

# EC2 DNS Entries
resource "cloudflare_record" "cname" {
  for_each = aws_instance.vm

  zone_id = var.cloudflare_zone_id
  name    = each.value.tags.DNS
  value   = each.value.public_dns
  type    = "CNAME"
  ttl     = 120
  proxied = false
}