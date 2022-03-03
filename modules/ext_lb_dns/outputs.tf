output "op_hostname" {
  value = aws_route53_record.op_CNAME.fqdn
}

output "nomad_hostname" {
  value = aws_route53_record.nomad_CNAME.fqdn
}

output "vms_hostname" {
  value = aws_route53_record.vms_CNAME.fqdn
}