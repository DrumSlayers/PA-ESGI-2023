#!/bin/bash
# simple user
echo $(whoami)  
echo '${join("\n", var.ssh_public_keys)}' >> /home/ubuntu/.ssh/authorized_keys
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install python3-pip -y

su - ubuntu
mkdir /home/ubuntu/.aws
chown -R ubuntu:ubuntu /home/ubuntu/.aws

cat << HEL >> /home/ubuntu/.aws/config
[plugins]
endpoint = awscli_plugin_endpoint
[default]
region = fr-par
s3 =
  endpoint_url = https://s3.fr-par.scw.cloud
s3api =
  endpoint_url = https://s3.fr-par.scw.cloud
HEL
chown ubuntu:ubuntu /home/ubuntu/.aws/config
pip3 install awscli
pip3 install awscli_plugin_endpoint

cat << HEL >> /home/ubuntu/.aws/credentials
[default]
aws_access_key_id = ${var.scaleway_access_key}
aws_secret_access_key = ${var.scaleway_secret_key}
HEL

chown ubuntu:ubuntu /home/ubuntu/.aws/config
chmod 600 /home/ubuntu/.aws/config