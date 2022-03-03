
data "aws_route53_zone" "circleci" {
  name = var.r53_hosted_zone_domain
}




data "kubernetes_service" "frontend_nlb" {
  metadata {
    name      = "circleci-server-traefik"
    namespace = var.circleci_server_k8s_namespace
  }
}
data "aws_lb" "frontend_nlb" {
  # the LB's "name" is the first 32 characters of its hostname -- an alphanumeric string in front of a hyphen
  name = split("-", data.kubernetes_service.frontend_nlb.status.0.load_balancer.0.ingress.0.hostname)[0]
}

data "kubernetes_service" "nomad_nlb" {
  metadata {
    name      = "nomad-server-external"
    namespace = var.circleci_server_k8s_namespace
  }
}

data "kubernetes_service" "output_processor_nlb" {
  metadata {
    name      = "output-processor"
    namespace = var.circleci_server_k8s_namespace
  }
}

data "kubernetes_service" "vms_nlb" {
  metadata {
    name      = "vm-service"
    namespace = var.circleci_server_k8s_namespace
  }
}