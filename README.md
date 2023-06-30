# Projet Annuel 2023
#### Table of contents
- [Projet Annuel 2023](#projet-annuel-2023)
      - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
    - [Membres du projet](#membres-du-projet)
    - [Topo](#topo)
  - [Requirements](#requirements)
    - [Installation of requirements](#installation-of-requirements)
      - [Terraform](#terraform)
        - [Backend remote tfstate](#backend-remote-tfstate)
        - [Multiple platform lock dependencies](#multiple-platform-lock-dependencies)
  - [Déploiement](#déploiement)
    - [Infrastructure Provisioning](#infrastructure-provisioning)
    - [Infrastructure Configuration](#infrastructure-configuration)
  - [AWS Academy Credentials scrapper](#aws-academy-credentials-scrapper)
    - [Usage](#usage)
  - [Documentation \& explainations](#documentation--explainations)
    - [For each module](#for-each-module)
    - [References](#references)

## Introduction
### Membres du projet
- Pierre SARRET
- Alexandre HELETA
- Florentin BEAULIEU
- Lucas DEBURE

### Topo
Nous sommes la société de prestation informatique RapidiCloud.

Mandatés par le client TransExpress, nous devons construire à neuf une infrastructure cloud-compatible pour répondre aux besoins de leur entreprise
- Téléphonie
- Mailing
- Un site web dynamique avec beaucoup de traffic

Le client souhaite installer son infrastructure sur AWS, en infra-as-code le plus possible.
Il souhaite également une documentation du projet complète et qualitative, afin qu'il puisse comprendre toute l'installation et réinstaller les travaux lui même au besoin.

> Plus de détails dans la suite du sujet dans les documents fonctionnels.

Pour des raisons de compréhension technique entre toutes les équipes intervenantes, le reste de cette documentation sera écrite en Anglais.

## Requirements
- Terraform >=1.3.x
- Ansible
    - aws_ec2 module

For [AWS Academy Credentials scrapper](#aws-academy-credentials-scrapper) :
- Python3
    - boto3
    - botocore
    - bs4
    - requests
    - selenium
    - dotenv
    - rich
- X Server (for Selenium, althrough not really used, so you don't need a full desktop environment)
- Chromium or Chrome

### Installation of requirements
Debian :
```bash
sudo apt install ansible python3-botocore python3-boto3 python3-bs4 python3-request python3-selenium python3-dotenv python3-rich

ansible-galaxy collection install amazon.aws
ansible-galaxy collection install community.mysql
```
#### Terraform
##### Backend remote tfstate
1. Copy `backend.conf.exemple` to `backend.conf` and edit the values with your Scaleway credentials	
2. Run ```terraform init -backend-config=backend.conf``` to verify the backend configuration and if it's working

##### Multiple platform lock dependencies
```bash
terraform providers lock \
    -platform=windows_amd64 \
    -platform=darwin_amd64 \
    -platform=linux_amd64 \
    -platform=darwin_arm64 \
    -platform=linux_arm64
```

## Déploiement
### Infrastructure Provisioning
1. Fetch the AWS credentials using [AWS Academy Credentials scrapper](#aws-academy-credentials-scrapper) script
2. Copy `terraform.tfvars.exemple` to `terraform.tfvars` and edit the values with your AWS Academy credentials
3. Use `terraform plan` to preview changes
4. Use `terraform apply` to apply changes

### Infrastructure Configuration
1. In `Ansible/` folder, copy each .example files to .yml files and edit the values with the required credentials (AWS, Remote database and various services configuration)
2. Run Ansible Playbook to configure each instance you want to configure.
   Playbooks are configured to match the right EC2 tags, so it automatically configure the targeted service.
   For exemple: 
   - `ansible-playbook -i ansible/aws_ec2.yml ansible/dolibarr-playbook.yml`
   Will configure Dolibarr EC2 instance.
3. In 'deploy-ec2/deploy-scripting/vm-nextcloud.tftpl' file, this running the deploy script for nextcloud.  
   - `sudo docker compose up --build -d ` to build the docker image and run the container.
   Nextcloud is accessible on https://host.transexpress.ovh/.      

## AWS Academy Credentials scrapper
The AWS Academy Learner Lab is giving new access tokens every 4 hours and at every lab start, so we need to scrap the token from the lab page automatically to prevent copying the values each time (very time consumming)

We are using Selenium with Chromium webdriver & BeautifulSoup python module for the web scrapping.
> ℹ️ The script does insert new credentials into `terraform.tfvars` file and `ansible/aws_ec2.yml` inventory description file

### Usage
1. Copy `.env.exemple` to `.env` and edit the values with your AWS Academy credentials	
2. Run ```python3 scrape_aws_credentials.py```

## Documentation & explainations
### For each module
You will find each module documentation in the /docs folder.
Direct links :

### References
- Ansible x Terraform x AWS 1 https://blog.stephane-robert.info/post/terraform-gitlab-aws-ansible/
- Ansible x Terraform x AWS 2 https://dev.to/mariehposa/how-to-deploy-an-application-to-aws-ec2-instance-using-terraform-and-ansible-3e78
