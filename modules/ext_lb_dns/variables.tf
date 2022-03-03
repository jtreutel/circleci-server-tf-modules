variable "region" {}

##Tag info
variable "team" {}
variable "owner" {}
variable "source_repo" {}

variable "r53_ttl" {
  default = "1" #low ttl for testing purposes
}

variable "circleci_server_k8s_namespace" {
  default = "circleci-server"
}

/*
variable "front_nlb_dns_name" {
  default = ""
}

variable "nomad_lb_dns_name" {
  default = "localhost"
}

variable "op_lb_dns_name" {
  default = "localhost"
}

variable "vms_lb_dns_name" {
  default = "localhost"
}
*/
