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
  sensitive   = true
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
