# Intro

I've created this project to prepare for the [AWS CCP exam](https://aws.amazon.com/certification/certified-cloud-practitioner).
The aim is to better understand the services used by setting up an infrastructure.

## Goals

- Deploy a containerized [Laravel](https://laravel.com) app to [ECS](https://aws.amazon.com/ecs)
- Connect to MariaDB database hosted on [RDS](https://aws.amazon.com/rds)
- Add Redis Cache via [ElastiCache](https://aws.amazon.com/elasticache).
- Use [Terraform](https://www.terraform.io) IaC inside of [GitHub actions](https://github.com/features/actions) to deploy the infrastructure

## Docs

The [Dockerfile](Dockerfile) makes use of [FrankenPHP](https://frankenphp.dev) and installs all of the required PHP extensions, [git](https://git-scm.com) and [npm](https://www.npmjs.com). It then installs the [composer](https://getcomposer.org) and npm dependencies. When the container is started the database is migrated before the server is started.

The following environment variables have to be set when running `terraform plan/apply`:

- `TF_VAR_rds_password` password for the admin user of the MariaDB database
- `TF_VAR_laravel_app_key` app key for the Laravel app
- `TF_VAR_alb_certificate_arn` ARN of a (self signed) certificate in ACM
