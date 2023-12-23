# Goals

This is a sample project that I use to prepare for the [AWS CCP exam](https://aws.amazon.com/certification/certified-cloud-practitioner).
My goal is to deploy a containerized [Laravel](https://laravel.com) app to [ECS](https://aws.amazon.com/ecs), host MySQL on [RDS](https://aws.amazon.com/rds) and Redis via [ElastiCache](https://aws.amazon.com/elasticache). All of which will be deployed using [Terraform](https://www.terraform.io) IaC inside of [GitHub actions](https://github.com/features/actions).

## Docker

The [Dockerfile](Dockerfile) makes use of [FrankenPHP](https://frankenphp.dev) and installs all of the required PHP extensions, [git](https://git-scm.com) and [npm](https://www.npmjs.com). It then installs the [composer](https://getcomposer.org) and npm dependencies and sets up some caching for the Laravel app.
