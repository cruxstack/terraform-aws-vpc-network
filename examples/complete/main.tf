module "vpc" {
  source = "../../"

  name                  = "tfexample-complete"
  availability_zones    = var.availability_zones
  vpc_ipv4_cidr         = var.vpc_ipv4_cidr
  nat_type              = var.nat_type
  vpc_flow_logs_enabled = false
}
