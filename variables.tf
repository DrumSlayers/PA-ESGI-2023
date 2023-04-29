variable "aws_region" {

  description = "Region of aws deployment"
  type        = string
  default     = "us-east-1"

}

variable "aws_access_key" {

  description = "AWS Access key for account"
  type        = string

}

variable "aws_secret_key" {

  description = "AWS Secret key for account"
  type        = string

}

variable "aws_token_session" {

  description = "AWS Session Token"
  type        = string

}

variable "ssh_key_name" {

  description = "Name of SSH Key"
  type        = string

}

variable "public_ssh_key" {

  description = "Public ssh key to add on aws account"
  type        = string

}

# Security Group

variable "sg_name" {
  type        = string
  description = "name of security group"
}


# egress

variable "sg_egress_protocol" {

  description = "Public ssh key to add on aws account"
  type        = string

}

variable "from_port_ingress" {
  description = "From port of ingress"
  type = number
}

variable "to_port_ingress" {
  description = "To port of ingress"
  type = number
}

variable "protocol_ingress" {
  description = "Protocol of ingress"
  type = string
}

variable "cidr_blocks_ingress" {
  description = "CIDR blocks of ingress"
  type = list(string)
}

variable "ipv6_cidr_blocks_ingress" {
  description = "IPv6 CIDR blocks of ingress"
  type = list(string)
}

variable "prefix_list_ids_ingress" {
  description = "Prefix list IDs of ingress"
  type = list(string)
}

variable "security_groups_ingress" {
  description = "Security groups of ingress"
  type = list(string)
}

variable "self_ingress" {
  description = "Self of ingress"
  type = bool
}

# egress

variable "from_port_egress" {
  description = "From port of egress"
  type = number
}

variable "to_port_egress" {
  description = "To port of egress"
  type = number
}

variable "ipv6_cidr_blocks_egress" {
  description = "IPv6 CIDR blocks of egress"
  type = list(string)
}

variable "prefix_list_ids_egress" {
  description = "Prefix list IDs of egress"
  type = list(string)
}

variable "cidr_blocks_egress" {
  description = "CIDR blocks of egress"
  type = list(string)
}

variable "self_egress" {
  description = "Self of egress"
  type = bool
}

variable "security_groups_egress" {
  description = "Security groups of egress"
  type = list(string)
}

variable "ami_id" {
  description = "AMI ID of the EC2 instance"
  type        = string
}
variable "ec2_instance_type" {
  description = "Type of EC2 instance"
  type        = string
}
variable "ec2_name" {
  description = "Name of EC2 instance"
  type        = string
}

variable "mount_point" {
  description = "Mount point of Bucket S3 in EC2"
  type = string 
}

# S3

variable "bucket_name" {
  description = "Name of Bucket S3"
  type        = string
}

# VPC
variable "vpc_cidr_block" {
  description = "CIDR Block for the EC2 VPC"
  type = string
}

variable "vpc_instance_tenancy" {
  description = "Tenancy for VPC"
  type = string
}

variable "vpc_subnet_cidr_block" {
  description = "CIDR BLock for the EC2 VPC Subnet"
  type = string
}

