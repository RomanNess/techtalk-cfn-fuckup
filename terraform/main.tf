terraform {
  required_version = "~> 1.0.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5"
    }
    local    = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

data "aws_caller_identity" "current" {}
