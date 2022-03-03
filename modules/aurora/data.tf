data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket  = "jennings-demo-terraform-state"
    key     = "server-migration-test/cluster-b/vpc/terraform.tfstate"
    region  = "ap-northeast-2"
    profile = "default"
  }
}

data "aws_region" "current" {}

locals {
  resource_prefix = "${data.terraform_remote_state.vpc.outputs.resource_prefix}-pg-ext"
}