#-------------------------------------------------------------------------------
# S3 BUCKET
#-------------------------------------------------------------------------------

resource "random_string" "s3_suffix" {
  length           = 16
  upper            = false
  special          = false
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.resource_prefix}-${random_string.s3_suffix.result}"
  force_destroy = true
}

resource "aws_iam_policy" "s3" {
  name        = "${var.resource_prefix}-s3"
  description = "CircleCI Server S3 Access policy."

  policy = templatefile(
    "${path.module}/templates/s3_policy.json.tpl",
    {
      aws_s3_bucket_s3_arn = aws_s3_bucket.s3.arn
    }
  )
}


### Resources for IAM User ###

resource "aws_iam_user" "s3" {
  count = var.use_iam_role_for_s3_access == true ? 0 : 1
  name  = "${var.resource_prefix}-s3"
}

resource "aws_iam_user_policy_attachment" "s3" {
  count      = var.use_iam_role_for_s3_access == true ? 0 : 1
  user       = aws_iam_user.s3[0].name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_iam_access_key" "s3" {
  count = var.use_iam_role_for_s3_access == true ? 0 : 1
  user  = aws_iam_user.s3[0].name
}

### Resources for IAM Role ###

resource "aws_iam_role" "s3" {
  count = var.use_iam_role_for_s3_access == true ? 1 : 0
  name  = "${var.resource_prefix}-s3"

  assume_role_policy = data.template_file.eks_oidc_assume.rendered
}

resource "aws_iam_role_policy_attachment" "s3" {
  count      = var.use_iam_role_for_s3_access == true ? 1 : 0
  role       = aws_iam_role.s3[0].name
  policy_arn = aws_iam_policy.s3.arn
}




#-------------------------------------------------------------------------------
# NOMAD CLIENT CLUSTER
#-------------------------------------------------------------------------------

module "nomad_clients" {
  source = "git::https://github.com/CircleCI-Public/server-terraform.git//nomad-aws?ref=3.3.0"

  nodes             = var.nomadc_desired_capacity
  vpc_id            = var.nomadc_vpc
  subnet            = var.nomadc_subnet
  instance_type     = var.nomadc_instance_type
  server_endpoint   = "nomad.${var.server_fqdn}:4647"
  nomad_auto_scaler = var.nomad_autoscaler_enabled

  dns_server    = ""
  blocked_cidrs = [for subnet in data.aws_subnet.services : subnet.cidr_block]

  basename = var.resource_prefix
  ssh_key  = var.nomadc_ssh_authorized_key
}

resource "aws_iam_policy" "nomad_autoscaler" {
  name        = "${var.resource_prefix}-nomad-autoscaler"
  description = "CircleCI Server Nomad Autoscaler policy."

  policy = templatefile(
    "${path.module}/templates/nomad_autoscaler_policy.json.tpl",
    {
      asg_arn = data.aws_autoscaling_group.nomad.arn
    }
  )
}

### Resources for IAM User ###

resource "aws_iam_user" "nomad_autoscaler" {
  count = var.use_iam_role_for_nomad_autoscaler == true ? 0 : 1
  name  = "${var.resource_prefix}-nomad-autoscaler"
}

resource "aws_iam_user_policy_attachment" "nomad_autoscaler" {
  count      = var.use_iam_role_for_nomad_autoscaler == true ? 0 : 1
  user       = aws_iam_user.nomad_autoscaler[0].name
  policy_arn = aws_iam_policy.nomad_autoscaler.arn
}

resource "aws_iam_access_key" "nomad_autoscaler" {
  count = var.use_iam_role_for_nomad_autoscaler == true ? 0 : 1
  user  = aws_iam_user.nomad_autoscaler[0].name
}

### Resources for IAM Role ###

resource "aws_iam_role" "nomad_autoscaler" {
  count = var.use_iam_role_for_nomad_autoscaler == true ? 1 : 0
  name  = "${var.resource_prefix}-nomad-autoscaler"

  assume_role_policy = data.template_file.eks_oidc_assume.rendered
}

resource "aws_iam_role_policy_attachment" "nomad_autoscaler" {
  count      = var.use_iam_role_for_nomad_autoscaler == true ? 1 : 0
  role       = aws_iam_role.nomad_autoscaler[0].name
  policy_arn = aws_iam_policy.nomad_autoscaler.arn
}


#-------------------------------------------------------------------------------
# VM SERVICE
#-------------------------------------------------------------------------------

resource "aws_security_group" "vms" {
  name        = "${var.resource_prefix}-vms"
  description = "SG rules required by VM service of CircleCI"
  vpc_id      = data.aws_subnet.vms.vpc_id

  ingress = [
    {
      description = "The port for control over SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = concat(
        var.vms_public ? [for natgw in data.aws_nat_gateway.services : "${natgw.public_ip}/32"] : [],
        var.vms_public ? ["0.0.0.0/0"] : [] # We need 0.0.0.0/0 because we do not know source addresses used by Nomad clients when a public address is assigned to VMs
      )
      security_groups = concat(
        [for config in data.aws_eks_cluster.services.vpc_config : config.cluster_security_group_id],
        [module.nomad_clients.nomad_sg_id]
      )

      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    },
    {
      description = "The port for access to remote Docker daemon"
      from_port   = 2376
      to_port     = 2376
      protocol    = "tcp"
      cidr_blocks = concat(
        var.vms_public ? [for natgw in data.aws_nat_gateway.services : "${natgw.public_ip}/32"] : [],
        var.vms_public ? ["0.0.0.0/0"] : [] # We need 0.0.0.0/0 because we do not know source addresses used by Nomad clients when a public address is assigned to VMs
      )
      security_groups = concat(
        [for config in data.aws_eks_cluster.services.vpc_config : config.cluster_security_group_id],
        [module.nomad_clients.nomad_sg_id]
      )

      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    },
    {
      description      = "The port for rerun with SSH"
      from_port        = 54782
      to_port          = 54782
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]

      prefix_list_ids = []
      security_groups = []
      self            = false
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]

      description     = ""
      prefix_list_ids = []
      security_groups = []
      self            = false
    }
  ]
}

resource "aws_iam_policy" "vms" {
  name        = "${var.resource_prefix}-vms"
  description = "CircleCI Server VM Service policy."

  policy = templatefile(
    "${path.module}/templates/vms_policy.json.tpl",
    {
      vpc_id    = data.aws_subnet.vms.vpc_id
      vms_sg_id = aws_security_group.vms.id
    }
  )
}

### Resources for IAM User ###

resource "aws_iam_user" "vms" {
  count = var.use_iam_role_for_vm_service == true ? 0 : 1
  name  = "${var.resource_prefix}-vms"
}

resource "aws_iam_user_policy_attachment" "vms" {
  count      = var.use_iam_role_for_vm_service == true ? 0 : 1
  user       = aws_iam_user.vms[0].name
  policy_arn = aws_iam_policy.vms.arn
}

resource "aws_iam_access_key" "vms" {
  count = var.use_iam_role_for_vm_service == true ? 0 : 1
  user  = aws_iam_user.vms[0].name
}

### Resources for IAM Role ###

resource "aws_iam_role" "vms" {
  count = var.use_iam_role_for_vm_service == true ? 1 : 0
  name  = "${var.resource_prefix}-vms"

  assume_role_policy = data.template_file.eks_oidc_assume.rendered
}

resource "aws_iam_role_policy_attachment" "vms" {
  count      = var.use_iam_role_for_vm_service == true ? 1 : 0
  role       = aws_iam_role.vms[0].name
  policy_arn = aws_iam_policy.vms.arn
}




