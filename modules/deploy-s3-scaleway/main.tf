terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
      version = "2.18.0"
    }
  }
}

resource "scaleway_object_bucket" "main" {
  name = var.scaleway_bucket_name
  region = var.scaleway_region
  project_id = var.scaleway_project_id
  tags = {
    key = "bucket S3 - Projet"
  }
}

output "bucket_name" {
  value = scaleway_object_bucket.main.name
}