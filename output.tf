output "vm-dns" {
  description = "Nom DNS public de nos EC2"
  value       = "${module.deploy-ec2.vm-dns}"
}