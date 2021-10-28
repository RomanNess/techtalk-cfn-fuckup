variable "region" {
  description = "The AWS region"
  default     = "eu-central-1"
}

variable "stage" {
  type = string
  default = "staging"
}

variable "deployment_name" {
  type        = string
  description = "name prefix for resources"
  default = "cfn-fuckup"
}

variable "repo_name" {
  type = string
  default = "cfn-fuckup"
}

variable "common_tags" {
  type        = map(string)
  description = "common AWS resource tags"
  default     = {}
}

variable "number_of_azs" {
  type        = number
  description = "The number of subnets to use (1 - 3 in eu-central-1)."
  default     = 2
}

variable "route53_subdomain" {
  default = "cfn-fuckup.cosee.biz"
}

variable "ecs_docker_image" {
  default = "alexwhen/docker-2048"
}

locals {
  resource_prefix = "${var.deployment_name}-${var.stage}"
  aws_account_id  = data.aws_caller_identity.current.account_id

  common_tags = merge(var.common_tags, {
    deployment = var.deployment_name
    managedby  = var.repo_name
    stage      = var.stage
  })
}
