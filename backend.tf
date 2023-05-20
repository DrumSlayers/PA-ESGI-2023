terraform {
  backend "s3" {
    region         = "fr-par"
    endpoint       = "https://s3.fr-par.scw.cloud"
    skip_region_validation = true
    skip_credentials_validation = true
    skip_metadata_api_check = true
    force_path_style = true
  }
}