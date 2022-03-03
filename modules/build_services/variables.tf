variable "resource_prefix" {}
variable "public_subnets" {}
variable "eks_subnet_count" {}
variable "server_fqdn" {}
variable "eks_cluster_name" {}
variable "nomadc_vpc" {}
variable "nomadc_subnet" {}
variable "nomadc_ssh_authorized_key" {}
variable "nomadc_instance_type" {}
variable "nomadc_desired_capacity" {}
variable "nomad_autoscaler_enabled" {}
variable "vms_subnet" {}
variable "vms_public" {}

variable "use_iam_role_for_nomad_autoscaler" {}
variable "use_iam_role_for_s3_access" {}
variable "use_iam_role_for_vm_service" {}

variable "eks_oidc_provider_arn" {}
variable "eks_cluster_oidc_issuer_url" {}