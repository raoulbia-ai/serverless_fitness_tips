locals {
  domain = "bsisandbox.com"

  environment = replace(var.environment, "_", "-")

  site_domain = "fitness.${local.domain}"
}