# AWS Production-Ready Infrastructure

Projet pédagogique visant à concevoir une infrastructure AWS reproductible,
sécurisée et observable à l'aide de Terraform.

## Objectifs

- Décrire l'infrastructure avec Terraform.
- Conteneuriser une application web avec Docker.
- Explorer Amazon ECR et Amazon ECS avec AWS Fargate.
- Mettre en place une CI/CD avec GitHub Actions et OIDC.
- Comprendre les contrôles de sécurité et la supervision avec CloudWatch.
- Maîtriser les coûts et supprimer les ressources de test après utilisation.

## Région cible

Europe (Paris) — eu-west-3

## Principes de sécurité et de coûts

- Aucun secret ou état Terraform dans Git.
- Permissions IAM limitées au strict nécessaire.
- Aucun déploiement AWS sans validation explicite.
- Estimation des coûts avant toute création de ressources payantes.

## Statut

Phase de préparation locale. Aucun déploiement AWS effectué.
