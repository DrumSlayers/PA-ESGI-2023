output "vm-dns" {
  description = "Nom DNS public de nos EC2"
  value = {
    for instance in aws_instance.vm : instance.tags["Name"] => instance.public_dns
  }
}

output "ec2_instance_ids" {
  value = { for key, instance in aws_instance.vm : key => instance.id }
}
