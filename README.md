# Projet Annuel 2023 - Introduction
## Membres du projet
- Pierre SARRET
- Alexandre HELETA
- Florentin BEAULIEU
- Lucas DEBURE

## Introduction
Nous sommes la société de prestation informatique RapidiCloud.

Mandatés par un client, nous devons construire à neuf une infrastructure cloud-compatible pour répondre aux besoins de leur entreprise
- Téléphonie
- Mailing
- Un site web dynamique avec beaucoup de traffic

Le client souhaite installer son infrastructure sur AWS, en infra-as-code le plus possible.
Il souhaite également une documentation du projet complète et qualitative, afin qu'il puisse comprendre toute l'installation et réinstaller les travaux lui même au besoin.

## Requirements
## Configuration
> Cette configuration est exclusivement dédiée au projet annuel ESGI. Nous utilisons un AWS Education.
1. Connectez vous à https://www.awsacademy.com/vforcesite/LMS_Login
2. Rendez vous dans Courses -> ALLv1 -> Modules -> Learner Lab
3. Lancez le LAB
4. Récupérez les informations AWS (tokens & co) et éditer terraform.tfvars avec celles-ci

## Déploiement
1. `terraform init`
2. `terraform plan / deploy`

# A faire
Voir discord channel #tache-a-faire
Au 29/04/23
- Check IAM & droits dédiés
- Book points/rdv avec Ettayeb
- Trouver une solution pertinente pour les données permanente (backblaze ou minio sur un de nos serveurs hors AWS)