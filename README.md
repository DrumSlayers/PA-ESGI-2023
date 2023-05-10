# Projet Annuel 2023 - Introduction
## Membres du projet
- Pierre SARRET
- Alexandre HELETA
- Florentin BEAULIEU
- Lucas DEBURE

## Topo
Nous sommes la société de prestation informatique RapidiCloud.

Mandatés par un client, nous devons construire à neuf une infrastructure cloud-compatible pour répondre aux besoins de leur entreprise
- Téléphonie
- Mailing
- Un site web dynamique avec beaucoup de traffic

Le client souhaite installer son infrastructure sur AWS, en infra-as-code le plus possible.
Il souhaite également une documentation du projet complète et qualitative, afin qu'il puisse comprendre toute l'installation et réinstaller les travaux lui même au besoin.

# Requirements
- Terraform >=1.3.x
- Ansible
    - aws_ec2 module
- Python3
    - boto3
    - botocore
    - bs4
    - requests
    - selenium (Looking to replacing it as it install everything X related, but it's working for now)

### Installation of requirements
Debian :
```bash
sudo apt install ansible python3-botocore python3-boto3 python3-bs4 python3-request python3-selenium
ansible-galaxy collection install amazon.aws
```

## AWS Canvas Learner Lab Token scrapping
The AWS Student Learner Lab is giving new access tokens every 4 hours and at every lab start, so we need to scrap the token from the lab page automatically to prevent copying the values each time (very time consumming)

We are using Selenium with Chromium webdriver & BeautifulSoup python module for the web scrapping.

```python3 scrape_aws_credentials.py```

## Configuration
> Cette configuration est exclusivement dédiée au projet annuel ESGI. Nous utilisons un AWS Education.
1. Connectez vous à https://www.awsacademy.com/vforcesite/LMS_Login
2. Rendez vous dans Courses -> ALLv1 -> Modules -> Learner Lab
3. Lancez le LAB
4. Récupérez les informations AWS (tokens & co) et éditer terraform.tfvars avec celles-ci

# Déploiement
1. `terraform init`
2. `terraform plan / deploy`

# A faire
Voir discord channel #tache-a-faire
Au 29/04/23
- Check IAM & droits dédiés
- Book points/rdv avec Ettayeb
- Trouver une solution pertinente pour les données permanente (backblaze ou minio sur un de nos serveurs hors AWS)


# Documentation
- Ansible x Terraform x AWS 1 https://blog.stephane-robert.info/post/terraform-gitlab-aws-ansible/
- Ansible x Terraform x AWS 2 https://dev.to/mariehposa/how-to-deploy-an-application-to-aws-ec2-instance-using-terraform-and-ansible-3e78
