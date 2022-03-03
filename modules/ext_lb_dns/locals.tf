locals {
  server_fqdn            = data.terraform_remote_state.server.outputs._00_00_server_fqdn
  server_subdomain       = data.terraform_remote_state.server.outputs._99_01_server_subdomain
  r53_hosted_zone_domain = data.terraform_remote_state.server.outputs._99_02_r53_hosted_zone_domain
}