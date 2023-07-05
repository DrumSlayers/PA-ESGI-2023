## AWS
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

## VPC
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
    "Project"     = "TransexpressWebsite"
    "Environment" = "Production"
  }
}

## Cluster
variable "scaling_config_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "scaling_config_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "scaling_config_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "ami_type_eks" {
  description = "Amazon Machine Image (AMI) type for the EKS nodes"
  type        = string
}

variable "disk_size_eks_node" {
  description = "Disk size for the EKS nodes"
  type        = number
}

variable "instance_types_eks_node" {
  description = "Instance type for the EKS nodes"
  type        = string
}

## Cloudflare
variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "cloudflare_api_token" {
  description = "API token for Cloudflare"
  type        = string
}
variable "cloudflare_dns_entry_name" {
  description = "DNS entry name for the EKS cluster in Cloudflare"
  type        = string
}

## Github
variable "github_token" {
  description = "Token identification for github actions"
  type        = string
}
variable "github_repo_name" {
  description = "Name of the GitHub repository"
  type        = string
}

variable "kubeconfig_secret_name" {
  description = "Name of the secret in GitHub for the kubeconfig"
  type        = string
}

variable "aws_access_key_id_secret_name" {
  description = "Name of the secret in GitHub for the AWS access key ID"
  type        = string
}

variable "aws_region_secret_name" {
  description = "Name of the secret in GitHub for the AWS region"
  type        = string
}

variable "aws_secret_access_key_secret_name" {
  description = "Name of the secret in GitHub for the AWS secret access key"
  type        = string
}

variable "aws_session_token_secret_name" {
  description = "Name of the secret in GitHub for the AWS session token"
  type        = string
}

## Kubernetes
variable "kube_deploy_name" {
  description = "Name of the Kubernetes Deployment"
  type        = string
}

variable "kube_deploy_label" {
  description = "Label for the Kubernetes Deployment"
  type        = string
}

variable "kube_deploy_container_name" {
  description = "Name of the container in the Kubernetes Deployment"
  type        = string
}

variable "kube_deploy_image" {
  description = "Image to use for the container in the Kubernetes Deployment"
  type        = string
}

variable "kube_deploy_pull_policy" {
  description = "Image pull policy for the container in the Kubernetes Deployment"
  type        = string
}

variable "kube_deploy_port" {
  description = "Port for the container in the Kubernetes Deployment"
  type        = number
}

variable "kube_deploy_request_cpu" {
  description = "CPU request for the container in the Kubernetes Deployment"
  type        = string
}

variable "kube_deploy_request_memory" {
  description = "Memory request for the container in the Kubernetes Deployment"
  type        = string
}

variable "kube_deploy_limits_cpu" {
  description = "CPU limit for the container in the Kubernetes Deployment"
  type        = string
}

variable "kube_deploy_limits_memory" {
  description = "Memory limit for the container in the Kubernetes Deployment"
  type        = string
}

variable "kube_service_name" {
  description = "Name of the Kubernetes Service"
  type        = string
}

variable "kube_service_port" {
  description = "Port for the Kubernetes Service"
  type        = number
}

variable "kube_service_target_port" {
  description = "Target port for the Kubernetes Service"
  type        = number
}

variable "kube_service_type" {
  description = "Type of the Kubernetes Service (e.g., LoadBalancer, NodePort, ClusterIP)"
  type        = string
}

variable "kube_deploy_replicas" {
  description = "The number of desired replicas of this deployment"
  type        = number
}

