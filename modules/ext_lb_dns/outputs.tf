output "_02_00_op_hostname" {
  value = aws_route53_record.op_CNAME.fqdn
}

output "_03_00_nomad_hostname" {
  value = aws_route53_record.nomad_CNAME.fqdn
}

output "_04_00_vms_hostname" {
  value = aws_route53_record.vms_CNAME.fqdn
}