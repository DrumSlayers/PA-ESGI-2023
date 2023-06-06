#Déclaration du module deploy-ec2 avec ces variables 
module "deploy-ec2" {
  depends_on = [
    module.deploy-s3-scaleway
  ]
  source                   = "./modules/deploy-ec2"
  ssh_public_keys          = var.ssh_public_keys
  sg_name                  = var.sg_name
  cidr_blocks_ingress      = var.cidr_blocks_ingress
  from_port_ingress        = var.from_port_ingress
  ipv6_cidr_blocks_ingress = var.ipv6_cidr_blocks_ingress
  prefix_list_ids_ingress  = var.prefix_list_ids_ingress
  protocol_ingress         = var.protocol_ingress
  security_groups_ingress  = var.security_groups_ingress
  self_ingress             = var.self_ingress
  to_port_ingress          = var.to_port_ingress
  from_port_egress         = var.from_port_egress
  to_port_egress           = var.to_port_egress
  sg_egress_protocol       = var.sg_egress_protocol
  cidr_blocks_egress       = var.cidr_blocks_egress
  self_egress              = var.self_egress
  ipv6_cidr_blocks_egress  = var.ipv6_cidr_blocks_egress
  prefix_list_ids_egress   = var.prefix_list_ids_egress
  security_groups_egress   = var.security_groups_egress
  ami_id                   = var.ami_id
  ec2_instance_type        = var.ec2_instance_type
  ec2_name                 = var.ec2_name
  ec2_name_storage         = var.ec2_name_storage
  ec2_volume_size          = var.ec2_volume_size
  ec2_volume_type          = var.ec2_volume_type
  aws_session_token        = var.aws_session_token
  aws_secret_access_key    = var.aws_secret_access_key
  aws_access_key_id        = var.aws_access_key_id 
  bucket_name              = var.bucket_name
  mount_point              = var.mount_point
  vpc_cidr_block           = var.vpc_cidr_block
  vpc_instance_tenancy     = var.vpc_instance_tenancy
  vpc_subnet_cidr_block    = var.vpc_subnet_cidr_block
  scaleway_access_key      = var.scaleway_access_key
  scaleway_secret_key      = var.scaleway_secret_key
  cloudflare_zone_id       = var.cloudflare_zone_id
}

# declaration du module deploy-s3-scaleway
module "deploy-s3-scaleway" {
  source = "./modules/deploy-s3-scaleway"
  scaleway_access_key = var.scaleway_access_key
  scaleway_secret_key = var.scaleway_secret_key
  scaleway_bucket_name = var.scaleway_bucket_name
  scaleway_organization_id = var.scaleway_organization_id
  scaleway_region = var.scaleway_region
  scaleway_project_id = var.scaleway_project_id
  scaleway_bucket_initial_name = var.scaleway_bucket_initial_name
  scaleway_num_buckets = var.scaleway_num_buckets
}