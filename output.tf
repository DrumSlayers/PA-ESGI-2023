output "dolibarr-dns" {
  description = "Nom DNS public de notre EC2 Dolibarr"
    value = "${module.deploy-ec2.dolibarr-dns}"
    }

output "nextcloud-dns" {
  description = "Nom DNS public de notre EC2 Nextcloud"
    value = "${module.deploy-ec2.nextcloud-dns}"
}

# debug template
/* output "rendered-tpl1" {
    value = "${module.deploy-ec2.rendered-tpl1}"
}

output "rendered-tpl2" {
    value = "${module.deploy-ec2.rendered-tpl2}"
} */
