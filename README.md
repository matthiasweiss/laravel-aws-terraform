# Intro

I've created this project to better understand the services used by by this infrastructure in order to prepare for the [AWS CCP exam](https://aws.amazon.com/certification/certified-cloud-practitioner).

Disclaimer: this type of infrastructure is absolutely unnecessary for a simple web application, it would be much easier and cheaper to host the server on [EC2](https://aws.amazon.com/ec2) or [Lightsail](https://aws.amazon.com/lightsail)

# Goals

- Deploy a containerized [Laravel](https://laravel.com) app to [ECS](https://aws.amazon.com/ecs)
- Connect to [MariaDB](https://mariadb.org) database hosted on [RDS](https://aws.amazon.com/rds)
- Use [Terraform](https://www.terraform.io) IaC inside of [GitHub actions](https://github.com/features/actions) to deploy the infrastructure
- (Optional) Add Redis Cache via [ElastiCache](https://aws.amazon.com/elasticache).

# How it works

The [Dockerfile](Dockerfile) makes use of [FrankenPHP](https://frankenphp.dev) and installs all of the required PHP extensions, [git](https://git-scm.com) and [npm](https://www.npmjs.com). It then installs the [composer](https://getcomposer.org) and npm dependencies. When the container is started the database is migrated before the server is started. The Docker image is automatically built using a [GitHub action](./.github/workflows/publish-image.yaml)

The infrastructure is planned and provisioned using `terraform plan` and `terraform apply` respectively. The following environment variables have to be set for both commands to work:

- `TF_VAR_rds_password` password for the admin user of the MariaDB database
- `TF_VAR_laravel_app_key` app key for the Laravel app
- `TF_VAR_alb_certificate_arn` [ARN](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference-arns.html) of a (self signed) certificate in [ACM](https://aws.amazon.com/certificate-manager)

# Notes

The initial version of this project had the ECS service and RDS database in private subnets and a NAT gateway to enable outbound internet traffic. This was the most obvious solution for me at the time. I've re-structured the infrastructure to drop these private subnets and NAT gateways and put the ECS service and RDS database into a public subnet. Security groups make sure that the ECS service is only accessible by the load balancer and the database is only accessible by the ECS service. The original infrastructure can be found in the `private_subnets_and_nat_gateways` branch.
