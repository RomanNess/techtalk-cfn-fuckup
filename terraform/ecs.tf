data "aws_route53_zone" "default" {
  name = "${var.route53_subdomain}."
}

resource "aws_route53_record" "api" {
  name    = "www"
  type    = "CNAME"
  records = [
    module.alb.alb_dns_name
  ]
  ttl     = 300
  zone_id = data.aws_route53_zone.default.id
}

module "acm_request_certificate" {
  source  = "cloudposse/acm-request-certificate/aws"
  version = "~> 0.15.1"

  domain_name = "www.${var.route53_subdomain}"
  zone_name   = data.aws_route53_zone.default.name

  tags = local.common_tags
}

module "alb" {
  source  = "cloudposse/alb/aws"
  version = "~> 0.35.3"

  vpc_id              = aws_vpc.vpc.id
  subnet_ids          = aws_subnet.public.*.id
  security_group_ids  = [
    aws_security_group.alb.id
  ]
  certificate_arn     = module.acm_request_certificate.arn
  https_enabled       = true
  http_redirect       = true
  access_logs_enabled = false
  health_check_path   = "/health"

  tags = local.common_tags
}

# ECS Cluster (needed even if using FARGATE launch type)
resource "aws_ecs_cluster" "default" {
  name = local.resource_prefix
  tags = local.common_tags
}

module "default_backend_web_app" {
  source  = "cloudposse/ecs-web-app/aws"
  version = "~> 0.65.2"

  name = local.resource_prefix

  region      = var.region
  launch_type = "FARGATE"
  vpc_id      = aws_vpc.vpc.id

  container_environment = [
    {
      name  = "LAUNCH_TYPE"
      value = "FARGATE"
    },
    {
      name  = "VPC_ID"
      value = aws_vpc.vpc.id
    },
    {
      name  = "PORT"
      value = "80"
    },
  ]

  desired_count    = 1
  container_image  = var.ecs_docker_image
  container_cpu    = 256
  container_memory = 512
  container_port   = 80

  codepipeline_enabled = false
  webhook_enabled      = false

  aws_logs_region        = var.region
  ecs_cluster_arn        = aws_ecs_cluster.default.arn
  ecs_cluster_name       = aws_ecs_cluster.default.name
  ecs_security_group_ids = [
    aws_security_group.api_ingress.id,
    aws_security_group.egress_all.id,
  ]
  ecs_private_subnet_ids = aws_subnet.private.*.id

  alb_security_group = aws_security_group.alb.id
  alb_arn_suffix     = module.alb.alb_arn_suffix

  alb_ingress_unauthenticated_listener_arns       = module.alb.listener_arns
  alb_ingress_unauthenticated_listener_arns_count = 1
  alb_ingress_unauthenticated_paths               = [
    "/*"
  ]
  alb_ingress_authenticated_hosts = []
  ignore_changes_task_definition                  = false
}
