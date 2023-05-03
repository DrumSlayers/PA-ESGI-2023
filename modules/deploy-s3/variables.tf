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

variable "bucket_name" {

  description = "Name of Bucket S3"
  type        = string

}

variable "ec2-public-ip" {
    description = "Public IP of EC2 build in EC2 module"
    type        = string
}
