provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner       = "Todd"
      Provisioner = "Terraform"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  alias = "virginia"
}

terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}