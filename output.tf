#Output de l'ip publique pour faciliter la connection à l'EC2
output "public-ip" {
    value = "${module.deploy-ec2.public-ip}"
}