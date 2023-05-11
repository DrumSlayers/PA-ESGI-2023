terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65.0"
      
    }
    scaleway = {
      source = "scaleway/scaleway"
      version = "2.18.0"
    }
  }
}

provider "aws" {
  # Configuration du provider aws et authentification
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  token      = var.aws_session_token
}

provider "scaleway" {
  # Configuration du provider scaleway et authentification
  access_key = var.scaleway_access_key
  secret_key = var.scaleway_secret_key
  organization_id = var.scaleway_organization_id
  region = var.scaleway_region
}