provider "aws" {
  region = var.region
}

terraform {
  backend "local" {
  }
}


terraform {
  required_version = "~> 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5"
    }
    local    = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
}

data "aws_caller_identity" "current" {}