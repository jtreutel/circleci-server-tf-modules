output "server_fqdn" {
  value = var.server_fqdn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.s3.id
}

output "s3_bucket_region" {
  value = aws_s3_bucket.s3.region
}

output "s3_aws_access_key_id" {
  value = aws_iam_access_key.s3[0].id
}

output "s3_aws_secret_access_key" {
  value = nonsensitive(aws_iam_access_key.s3[0].secret)
}

output "s3_aws_role_arn" {
  value = "NOT YET ADDED"
}

output "nomad_server_cert" {
  value = module.nomad_clients.nomad_server_cert
}

output "nomad_server_key" {
  value = module.nomad_clients.nomad_server_key
}

output "nomad_ca" {
  value = module.nomad_clients.nomad_tls_ca
}

output "nomad_aws_access_key_id" {
  value = module.nomad_clients.nomad_asg_user_access_key
}

output "nomad_aws_secret_key_id" {
  value = nonsensitive(module.nomad_clients.nomad_asg_user_secret_key)
}

output "nomad_aws_role_arn" {
  value = "NOT YET ADDED"
}

output "nomad_asg_name" {
  value = module.nomad_clients.nomad_asg_name
}

output "vms_subnet" {
  value = data.aws_subnet.vms.id
}

output "vms_sg" {
  value = aws_security_group.vms.id
}

output "vms_aws_access_key_id" {
  value = aws_iam_access_key.vms[0].id
}

output "vms_aws_secret_access_key" {
  value = nonsensitive(aws_iam_access_key.vms[0].secret)
}

output "vms_aws_role_arn" {
  value = "NOT YET ADDED"
}