#Output de l'ip publique pour faciliter la connection à l'EC2
output "dolibarr-dns" {
  description = "Nom DNS public de notre EC2 Dolibarr"
  value       = aws_instance.ec2-dolibarr.public_dns
}

output "nextcloud-dns" {
  description = "Nom DNS public de notre EC2 Nextcloud"
  value       = aws_instance.ec2-nextcloud.public_dns
}

# debug template
/* 
output "rendered-tpl1" {
  value = templatefile("${path.module}/deploy-scripts/dolibarr.sh", local.vars)
}

output "rendered-tpl2" {
  value = templatefile("${path.module}/deploy-scripts/nextcloud.sh", local.vars)
} */
