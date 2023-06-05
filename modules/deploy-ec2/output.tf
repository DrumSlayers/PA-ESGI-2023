#Output de l'ip publique pour faciliter la connection à l'EC2
output "public-ip" {
  description = "Adresse IP publique de notre instance EC2"
  value       = aws_instance.ec2-dolibarr.public_ip
}