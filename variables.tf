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
/* 
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

variable "ec2_name_storage" {
  description = "Name of EC2 instance"
  type        = string
}


variable "ec2_volume_size" {
  description = "Volume size for EC2"
  type        = number
}

variable "ec2_volume_type" {
  description = "Volume type for EC2"
  type        = string
}  
*/

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

variable "scaleway_access_key" {
    description = "Scaleway Access Key"
    type        = string
}

variable "scaleway_secret_key" {
    description = "Scaleway secret key"
    type        = string
}

variable "scaleway_bucket_name" {
    description = "Scaleway bucket name"
    type        = string
}

variable "scaleway_organization_id" {
    description = "Scaleway organization id"
    type        = string
}

variable "scaleway_region" {
    description = "Scaleway region"
    type        = string
}

variable "scaleway_project_id" {
    description = "Scaleway project id"
    type        = string
}

variable "scaleway_bucket_initial_name" {
    description = "Scaleway bucket name"
    type        = string
}

variable "scaleway_num_buckets" {
    description = "Number of buckets to create"
    type        = number
}

variable "cloudflare_api_token" {
  description = "API token for Cloudflare"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "sns_phone_number" {
  description = "Phone number for SMS Alerts"
}

variable "sns_email_address" {
  description = "Email address for Email Alerts"
}

variable "sns_phone_number_guard" {
  description = "Phone number for SMS Alerts"
}

variable "sns_email_address_guard" {
  description = "Email address for Email Alerts"
}

variable "mysql_host" {
  description = "MySQL Host"
  type        = string
}

variable "mysql_database" {
  description = "MySQL Database"
  type        = string
}

variable "mysql_user" {
  description = "MySQL User"
  type        = string
}

variable "mysql_password" {
  description = "MySQL Password"
  type        = string
}

variable "redis_host" {
  description = "Redis Host"
  type        = string
}

variable "acme_email" {
  description = "ACME Email"
  type        = string
}

variable "acme_storage" {
  description = "ACME Storage Path"
  type        = string
}

variable "redis_password" {
  description = "Redis Password"
  type        = string
}

variable "redis_port" {
  description = "Redis Port"
  type        = number
}

variable "s3_bucket" {
  description = "S3 Bucket Name"
  type        = string
}

variable "s3_region" {
  description = "S3 Bucket Region"
  type        = string
}

variable "s3_key" {
  description = "S3 Access Key"
  type        = string
}

variable "s3_secret" {
  description = "S3 Secret Key"
  type        = string
}

variable "s3_hostname" {
  description = "S3 Hostname"
  type        = string
}

variable "s3_port" {
  description = "S3 Port"
  type        = number
}

variable "trusted_domain" {
  description = "Trusted Domains"
  type        = string
}

variable "trusted_proxy" {
  description = "Trusted Proxies"
  type        = string
}


## EKS
variable "project_eks" {
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  type = string
}

variable "vpc_cidr_eks" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_bits_eks" {
  description = "The number of subnet bits for the CIDR. For example, specifying a value 8 for this parameter will create a CIDR with a mask of /24."
  type        = number
  default     = 8
}
variable "github_token" {
  description = "token identification github"
  type        = string
}