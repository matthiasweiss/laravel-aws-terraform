# Intro

I've created this project to better understand the services used by by this infrastructure in order to prepare for the [AWS CCP exam](https://aws.amazon.com/certification/certified-cloud-practitioner).

Disclaimer: this type of infrastructure is not necessary for a simple web application, it would be much easier and cheaper to host the server on something like [Lightsail](https://aws.amazon.com/lightsail) or [DigitalOcean](https://www.digitalocean.com).

# Goals

- Deploy a containerized [Laravel](https://laravel.com) app to [ECS](https://aws.amazon.com/ecs)
- Connect to [MariaDB](https://mariadb.org) database hosted on [RDS](https://aws.amazon.com/rds)
- Use [Terraform](https://www.terraform.io) IaC inside of [GitHub actions](https://github.com/features/actions) to deploy the infrastructure
- (Optional) Add Redis Cache via [ElastiCache](https://aws.amazon.com/elasticache).

# How it works

The [Dockerfile](Dockerfile) makes use of [FrankenPHP](https://frankenphp.dev) and installs all of the required PHP extensions, [git](https://git-scm.com) and [npm](https://www.npmjs.com). It then installs the [composer](https://getcomposer.org) and npm dependencies. When the container is started the database is migrated before the server is started. The Docker image is automatically built using a [GitHub action](./.github/workflows/publish-image.yaml)

The infrastructure is planned and provisioned using `terraform plan` and `terraform apply` respectively. In order to be able to use Terraform to provision resources in AWS, the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables have to be set with valid keys. I created an IAM user with the required policies for this infrastructure and subsequently generated access keys for this user. Additionally, the following environment variables have to be set for both commands to work locally:

- `AWS_REGION` the AWS region you want to deploy in
- `TF_VAR_rds_password` password for the admin user of the MariaDB database
- `TF_VAR_laravel_app_key` app key for the Laravel app
- `TF_VAR_alb_certificate_arn` [ARN](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference-arns.html) of a (self signed) certificate in [ACM](https://aws.amazon.com/certificate-manager)

I have also added these environment variables as repository secrets / variables (depending on if they should be encrypted or not), so that they can be accessed inside a [GitHub action](.github/workflows/update-infrastructure.yaml).

# Notes

The initial version of this project had the ECS service in private subnets and a NAT gateway to enable outbound internet traffic. While this was the most obvious solution for me at the time, it turned out to be unnecessarily complex and expensive (the cost of NAT gateways is very high compared to the rest of the services, especially considering that each availability zone requires its own one). I have dropped the NAT gateways and moved the ECS service into the public subnets. Security groups make sure that the ECS service is only accessible by the load balancer. The RDS database remains in the private subnets. The original infrastructure can be found in the `private_subnets_and_nat_gateways` branch.
