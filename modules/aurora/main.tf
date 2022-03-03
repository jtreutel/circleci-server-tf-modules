resource "aws_rds_cluster" "circleci_server_external_postgres" {
  cluster_identifier      = replace(local.resource_prefix, "-", "")
  engine                  = "aurora-postgresql"
  availability_zones      = ["${var.region}a", "${var.region}b", "${var.region}c"]
  backup_retention_period = 1
  preferred_backup_window = "07:00-09:00"
  #instance_class    = "db.t4g.medium" # see https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
  master_username  = "cciadmin"
  master_password  = "CircleCI123!"
  backtrack_window = 0
  tags             = {}

  #explicitly defining these attributes to prevent TF destroy/create
  iam_database_authentication_enabled = false
  deletion_protection                 = false


  db_subnet_group_name   = aws_db_subnet_group.circleci_server_external_postgres.name
  vpc_security_group_ids = [aws_security_group.circleci_server_external_postgres.id]

  skip_final_snapshot       = true
  final_snapshot_identifier = "pleasedeleteme"
}

resource "aws_rds_cluster_instance" "circleci_server_external_postgres" {
  identifier         = "${replace(local.resource_prefix, "-", "")}-instance"
  cluster_identifier = aws_rds_cluster.circleci_server_external_postgres.id
  instance_class     = "db.r4.large"
  engine             = aws_rds_cluster.circleci_server_external_postgres.engine
  engine_version     = aws_rds_cluster.circleci_server_external_postgres.engine_version
}



resource "aws_db_subnet_group" "circleci_server_external_postgres" {
  name       = local.resource_prefix
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  tags = {
    Name = "${local.resource_prefix}-subnets"
  }
}

resource "aws_security_group" "circleci_server_external_postgres" {
  name        = local.resource_prefix
  description = "Allow Postgres connections from k8s cluster"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "Allow Postgres connections from within VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = local.resource_prefix
  }
}