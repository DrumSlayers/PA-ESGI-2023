terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.9"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

## Récupère les informations du rôle IAM existant avec le nom "LabRole"
data "aws_iam_role" "existing" {
  name = "LabRole"
}

## Recupère les zones disponibles dans la région
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.eks-cluster.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks-cluster.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

