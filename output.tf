output "vm-dns" {
  description = "Nom DNS public de nos EC2"
  value       = "${module.deploy-ec2.vm-dns}"
}
# debug template
/* output "rendered-tpl1" {
    value = "${module.deploy-ec2.rendered-tpl1}"
}

output "rendered-tpl2" {
    value = "${module.deploy-ec2.rendered-tpl2}"
} */
