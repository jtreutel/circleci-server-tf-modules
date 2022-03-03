data "aws_eks_cluster" "services" {
  name = var.eks_cluster_name
}
/*
data "aws_nat_gateway" "services" {
  for_each  = toset(var.public_subnets)
  subnet_id = each.value
  state     = "available"
}

data "aws_subnet" "services" {
  for_each = toset(flatten([for config in data.aws_eks_cluster.services.vpc_config : config.subnet_ids]))
  id       = each.value
}
*/
data "aws_nat_gateway" "services" {
  count = length(var.public_subnets)

  subnet_id = var.public_subnets[count.index]
  state     = "available"
}

data "aws_subnet" "services" {
  count = var.eks_subnet_count

  id = tolist(data.aws_eks_cluster.services.vpc_config[0].subnet_ids)[count.index]
}

data "aws_subnet" "vms" {
  id = var.vms_subnet
}

data "aws_autoscaling_group" "nomad" {
  name = module.nomad_clients.nomad_asg_name
}


data "template_file" "eks_oidc_assume" {
  template = "${path.module}/templates/eks_oidc_assume.json.tpl"
  vars = {
    eks_cluster_oidc_url = "${replace(var.eks_cluster_oidc_issuer_url, "https://", "")}",
    eks_cluster_oidc_arn = var.eks_oidc_provider_arn
  }
}

locals {

}