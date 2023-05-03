variable "aws_region" {

  description = "Region of aws deployment"
  type        = string
  default     = "us-east-1"

}

variable "aws_access_key_id" {

  description = "AWS Access key for account"
  type        = string

}

variable "aws_secret_access_key" {

  description = "AWS Secret key for account"
  type        = string

}

variable "aws_session_token" {

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
  type = number
}

variable "to_port_ingress" {
  type = number
}

variable "protocol_ingress" {
  type = string
}

variable "cidr_blocks_ingress" {
  type = list(string)
}

variable "ipv6_cidr_blocks_ingress" {
  type = list(string)
}

variable "prefix_list_ids_ingress" {
  type = list(string)
}

variable "security_groups_ingress" {
  type = list(string)
}

variable "self_ingress" {
  type = bool
}

# egress

variable "from_port_egress" {
  type = number
}

variable "to_port_egress" {
  type = number
}

variable "ipv6_cidr_blocks_egress" {
  type = list(string)
}

variable "prefix_list_ids_egress" {
  type = list(string)
}

variable "cidr_blocks_egress" {
  type = list(string)
}

variable "self_egress" {
  type = bool
}

variable "security_groups_egress" {
  type = list(string)
}

variable "ami_id" {}
variable "ec2_instance_type" {}
variable "ec2_name" {}

variable "bucket_name" {

  description = "Name of Bucket S3"
  type        = string

}

variable "mount_point" {
  description = "point de montage"
  type = string 
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
