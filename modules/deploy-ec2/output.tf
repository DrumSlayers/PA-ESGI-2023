output "vm-dns" {
  description = "Nom DNS public de nos EC2"
  //value       = aws_instance.ec2-nextcloud.public_dns
  value = {
    for instance in aws_instance.vm : instance.tags["Name"] => instance.public_dns
  }
}

output "ec2_instance_ids" {
  value = { for key, instance in aws_instance.vm : key => instance.id }
}
# debug template
/* 
output "rendered-tpl1" {
  value = templatefile("${path.module}/deploy-scripts/dolibarr.sh", local.vars)
}

output "rendered-tpl2" {
  value = templatefile("${path.module}/deploy-scripts/nextcloud.sh", local.vars)
} */
