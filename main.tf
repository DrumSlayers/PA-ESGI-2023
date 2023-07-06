#Déclaration du module deploy-ec2 avec ces variables 
module "deploy-ec2" {
  depends_on = [
    module.deploy-s3-scaleway
  ]
  source                   = "./modules/deploy-ec2"
  ssh_public_keys          = var.ssh_public_keys
  ec2-config               = var.ec2-config
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
  mysql_database           = var.mysql_database
  mysql_user               = var.mysql_user
  mysql_password           = var.mysql_password
  mysql_host               = var.mysql_host
  redis_host               = var.redis_host
  acme_email               = var.acme_email
  acme_storage             = var.acme_storage
  redis_password           = var.redis_password
  redis_port               = var.redis_port
  s3_bucket                = var.s3_bucket
  s3_region                = var.s3_region
  s3_key                   = var.s3_key
  s3_secret                = var.s3_secret
  s3_hostname              = var.s3_hostname
  s3_port                  = var.s3_port
  trusted_domain           = var.trusted_domain
  trusted_proxy            = var.trusted_proxy
  s3_bucket_name           = var.s3_bucket_name
  db_allocated_storage     = var.db_allocated_storage
  db_username              = var.db_username
  db_password              = var.db_password
  subnet_cidr_blocks       = var.subnet_cidr_blocks
  availability_zones       = var.availability_zones
  
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

# SNS Topic
module "sns" {
  depends_on = [
    module.deploy-ec2
  ]
  source = "./modules/sns"
  sns_phone_number  = var.sns_phone_number
  sns_email_address = var.sns_email_address
  sns_phone_number_guard = var.sns_phone_number_guard
  sns_email_address_guard = var.sns_email_address_guard
}

# Cloudwatch monitoring
module "cloudwatch_alarm" {
  depends_on = [
    module.sns
  ]
  for_each = module.deploy-ec2.ec2_instance_ids
  source = "./modules/cloudwatch"
  instance-id   = each.value
  sns_topic-arn = module.sns.sns_topic-arn
  sns_topic-arn-guardduty = module.sns.sns_topic-arn-guardduty
  instance-name = each.key
}

# Cluster EKS
module "eks" {
  source = "./modules/eks"
  aws_region = var.aws_region
  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  aws_session_token = var.aws_session_token
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id = var.cloudflare_zone_id
  project_eks = var.project_eks
  vpc_cidr_eks = var.vpc_cidr_eks
  subnet_cidr_bits_eks = var.subnet_cidr_bits_eks
  github_token = var.github_token
  scaling_config_desired_size = var.scaling_config_desired_size
  scaling_config_max_size = var.scaling_config_max_size
  scaling_config_min_size = var.scaling_config_min_size
  ami_type_eks = var.ami_type_eks
  disk_size_eks_node = var.disk_size_eks_node
  instance_types_eks_node = var.instance_types_eks_node
  cloudflare_dns_entry_name = var.cloudflare_dns_entry_name
  github_repo_name = var.github_repo_name
  kubeconfig_secret_name = var.kubeconfig_secret_name
  aws_access_key_id_secret_name = var.aws_access_key_id_secret_name
  aws_region_secret_name = var.aws_region_secret_name
  aws_secret_access_key_secret_name = var.aws_secret_access_key_secret_name
  aws_session_token_secret_name = var.aws_session_token_secret_name
  kube_deploy_name = var.kube_deploy_name
  kube_deploy_label = var.kube_deploy_label
  kube_deploy_container_name = var.kube_deploy_container_name
  kube_deploy_image = var.kube_deploy_image
  kube_deploy_pull_policy = var.kube_deploy_pull_policy
  kube_deploy_port = var.kube_deploy_port
  kube_deploy_request_cpu = var.kube_deploy_request_cpu
  kube_deploy_request_memory = var.kube_deploy_request_memory
  kube_deploy_limits_cpu = var.kube_deploy_limits_cpu
  kube_deploy_limits_memory = var.kube_deploy_limits_memory
  kube_service_name = var.kube_service_name
  kube_service_port = var.kube_service_port
  kube_service_target_port = var.kube_service_target_port
  kube_service_type = var.kube_service_type
  kube_deploy_replicas = var.kube_deploy_replicas
}

module "GuardDuty" {
  source = "./modules/GuardDuty"
}
