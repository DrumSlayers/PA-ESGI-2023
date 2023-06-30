terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
      version = "2.18.0"
    }
  }
}

locals {
  bucket_names = [for i in range(1, var.scaleway_num_buckets + 1): "${var.scaleway_bucket_initial_name}-${i}"]
}

resource "scaleway_object_bucket" "main" {
  for_each = toset(local.bucket_names)
  name = each.value
  region = var.scaleway_region
  project_id = var.scaleway_project_id
  tags = {
    key = "bucket S3 - Projet"
  }
}

output "bucket_names" {
  value = scaleway_object_bucket.main
}
