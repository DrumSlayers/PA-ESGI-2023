# Projet Annuel 2023
#### Table of contents

1. [Introduction](#introduction)
    * [Membres du projet](#membres-du-projet)
    * [Topo](#topo)
2. [Requirements](#requirements)
    * [Installation of requirements](#installation-of-requirements)
3. [Déploiement](#dploiement)
4. [AWS Academy Credentials scrapper](#aws-academy-credentials-scrapper)
5. [Usage](#usage)
6. [A faire](#a-faire)
7. [Documentation](#documentation)

## Introduction
### Membres du projet
- Pierre SARRET
- Alexandre HELETA
- Florentin BEAULIEU
- Lucas DEBURE

### Topo
Nous sommes la société de prestation informatique RapidiCloud.

Mandatés par un client, nous devons construire à neuf une infrastructure cloud-compatible pour répondre aux besoins de leur entreprise
- Téléphonie
- Mailing
- Un site web dynamique avec beaucoup de traffic

Le client souhaite installer son infrastructure sur AWS, en infra-as-code le plus possible.
Il souhaite également une documentation du projet complète et qualitative, afin qu'il puisse comprendre toute l'installation et réinstaller les travaux lui même au besoin.

## Requirements
- Terraform >=1.3.x
- Ansible
    - aws_ec2 module
- Python3
    - boto3
    - botocore
    - bs4
    - requests
    - selenium (Looking to replacing it as it install everything X related, but it's working for now)
    - dotenv
    - rich

### Installation of requirements
Debian :
```bash
sudo apt install ansible python3-botocore python3-boto3 python3-bs4 python3-request python3-selenium python3-dotenv python3-rich
```
ansible-galaxy collection install amazon.aws
```

## Déploiement
1. Fetch the AWS credentials using [AWS Academy Credentials scrapper](#aws-academy-credentials-scrapper) script
2. `terraform init`
3. `terraform plan / deploy`

## AWS Academy Credentials scrapper
The AWS Academy Learner Lab is giving new access tokens every 4 hours and at every lab start, so we need to scrap the token from the lab page automatically to prevent copying the values each time (very time consumming)

We are using Selenium with Chromium webdriver & BeautifulSoup python module for the web scrapping.
> ℹ️ The script does insert new credentials into `terraform.tfvars` file and `ansible/aws_ec2.yml` inventory description file

## Usage
1. Copy `.env.exemple` to `.env` and edit the values with your AWS Academy credentials	
2. Run ```python3 scrape_aws_credentials.py```


## A faire
Voir discord channel #tache-a-faire
Au 29/04/23
- Check IAM & droits dédiés
- Book points/rdv avec Ettayeb
- Trouver une solution pertinente pour les données permanente (backblaze ou minio sur un de nos serveurs hors AWS)


## Documentation
- Ansible x Terraform x AWS 1 https://blog.stephane-robert.info/post/terraform-gitlab-aws-ansible/
- Ansible x Terraform x AWS 2 https://dev.to/mariehposa/how-to-deploy-an-application-to-aws-ec2-instance-using-terraform-and-ansible-3e78
