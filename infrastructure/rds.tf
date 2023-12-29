resource "aws_db_subnet_group" "rds_db_default_subnet_group" {
  subnet_ids = [aws_subnet.private_subnet_az_a.id, aws_subnet.private_subnet_az_b.id]
}

# Password is stored in TF_VAR_rds_password environment variable
variable "rds_password" {
  type = string
}

variable "rds_database" {
  type    = string
  default = "aws_ccp_laravel"
}

resource "aws_db_instance" "mariadb" {
  allocated_storage    = 20
  db_name              = var.rds_database
  engine               = "mariadb"
  engine_version       = "10.6.14"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = var.rds_password
  db_subnet_group_name = aws_db_subnet_group.rds_db_default_subnet_group.name
  skip_final_snapshot  = true
}