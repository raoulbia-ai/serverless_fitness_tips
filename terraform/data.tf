data "aws_availability_zones" "this" {}

data "aws_caller_identity" "this" {}

data "aws_region" "current" {}

data "aws_route53_zone" "this" {
  name = local.domain

  private_zone = false
}