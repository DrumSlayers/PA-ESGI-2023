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

variable "availability_zones_count" {
  description = "The number of AZs."
  type        = number
  default     = 3
}

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

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    "Project"     = "TerraformEKSWorkshop"
    "Environment" = "Development"
  }
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "cloudflare_api_token" {
  description = "API token for Cloudflare"
  type        = string
}
variable "github_token" {
  description = "token identification github"
  type        = string
}
