# EC2 Declaration
variable "ec2-config" {
   description = "List of EC2 with their respective configuration"
}

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

variable "ssh_public_keys" {
  description = "List of public SSH keys to associate with the instance"
  type        = list(string)
}

# Security Group
/* 
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
variable "ec2_name_storage" {}

variable "ec2_volume_size" {
  description = "Volume size for EC2"
  type        = number
}
variable "ec2_volume_type" {
  description = "Volume type for EC2"
  type        = string
}

*/
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

variable "scaleway_access_key" {
  description = "Access key for Scaleway"
  type = string
}
  
variable "scaleway_secret_key" {
  description = "Secret key for Scaleway"
  type = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}