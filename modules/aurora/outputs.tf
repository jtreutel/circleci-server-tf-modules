output "_00_00_db_endpoint" {
  value = aws_rds_cluster_instance.circleci_server_external_postgres.endpoint
}

output "_00_01_db_port" {
  value = aws_rds_cluster.circleci_server_external_postgres.port
}

output "_00_02_db_master_username" {
  value = aws_rds_cluster.circleci_server_external_postgres.master_username
}

output "_00_03_db_master_password" {
  value = nonsensitive(aws_rds_cluster.circleci_server_external_postgres.master_password)
}