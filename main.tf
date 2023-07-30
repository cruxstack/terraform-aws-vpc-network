locals {
  enabled                               = module.this.enabled
  nat_aws_shield_protection_enabled     = local.enabled && var.nat_aws_shield_protection_enabled
  privatelink_enabled                   = local.enabled && (local.privatelink_vpc_endpoints_enabled || local.privatelink_gateway_endpoints_enabled)
  privatelink_vpc_endpoints_enabled     = local.enabled && length(var.privatelink_vpc_endpoints) > 0
  privatelink_gateway_endpoints_enabled = local.enabled && length(var.privatelink_gateway_endpoints) > 0
  vpc_flow_logs_enabled                 = local.enabled && var.vpc_flow_logs_enabled

  aws_account_id  = try(coalesce(var.aws_account_id, data.aws_caller_identity.current[0].account_id), "")
  aws_region_name = try(coalesce(var.aws_region_name, data.aws_region.current[0].name), "")

  subnet_max_count = (
    var.subnet_max_count > 0 ? var.subnet_max_count : (
      length(var.availability_zone_ids) > 0 ? length(var.availability_zone_ids) : length(var.availability_zones)
    )
  )
  privatelink_gateway_endpoint_map = {
    for v in var.privatelink_gateway_endpoints : lower(v) => {
      name            = lower(v)
      policy          = null
      route_table_ids = module.subnets.private_route_table_ids
    }
  }

  privatelink_vpc_endpoint_sg_key = "vpc-endpoint-interfaces"
  privatelink_vpc_endpoint_map = {
    for v in var.privatelink_vpc_endpoints : lower(v) => {
      name                = lower(v)
      policy              = null
      private_dns_enabled = true
      security_group_ids  = [module.privatelink_vpc_endpoint_sg[local.privatelink_vpc_endpoint_sg_key].id]
      subnet_ids          = module.subnets.private_subnet_ids
    }
  }
}

data "aws_caller_identity" "current" {
  count = module.this.enabled && var.aws_account_id == "" ? 1 : 0
}

data "aws_region" "current" {
  count = module.this.enabled && var.aws_region_name == "" ? 1 : 0
}

# ====================================================================== vpc ===

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.1.0"

  ipv4_primary_cidr_block          = var.vpc_ipv4_cidr
  assign_generated_ipv6_cidr_block = var.vpc_ipv6_cidr_auto_assigned
  internet_gateway_enabled         = var.public_subnets_enabled
  dns_hostnames_enabled            = true
  dns_support_enabled              = true

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.4.1"

  availability_zones              = var.availability_zones
  availability_zone_ids           = var.availability_zone_ids
  ipv4_cidr_block                 = [module.vpc.vpc_cidr_block]
  ipv4_cidrs                      = var.subnet_ipv4_cidrs
  ipv6_enabled                    = false
  igw_id                          = var.public_subnets_enabled ? [module.vpc.igw_id] : []
  map_public_ip_on_launch         = var.public_subnets_auto_assign_ip
  max_subnet_count                = local.subnet_max_count
  nat_gateway_enabled             = lower(var.nat_type) == "gateway"
  nat_instance_enabled            = lower(var.nat_type) == "instance"
  nat_instance_type               = var.nat_instance_size
  public_subnets_enabled          = var.public_subnets_enabled
  public_subnets_additional_tags  = var.public_subnets_extra_tags
  private_subnets_additional_tags = var.private_subnets_extra_tags
  vpc_id                          = module.vpc.vpc_id

  context = module.this.context
}

# -------------------------------------------------------------- privatelink ---

module "privatelink_vpc_endpoint_sg" {
  for_each = local.privatelink_vpc_endpoints_enabled ? toset([local.privatelink_vpc_endpoint_sg_key]) : []

  source  = "cloudposse/security-group/aws"
  version = "2.1.0"

  create_before_destroy      = true
  preserve_security_group_id = false
  attributes                 = [each.value]
  vpc_id                     = module.vpc.vpc_id
  allow_all_egress           = true

  rules_map = {
    ingress = [{
      key              = "vpc_ingress"
      type             = "ingress"
      from_port        = 0
      to_port          = 65535
      protocol         = "-1" # allow ping
      cidr_blocks      = compact(concat([module.vpc.vpc_cidr_block], module.vpc.additional_cidr_blocks))
      ipv6_cidr_blocks = compact(concat([module.vpc.vpc_ipv6_cidr_block], module.vpc.additional_ipv6_cidr_blocks))
      description      = "ingress from vpc to ${each.value}"
    }]
  }

  context = module.this.context
}

module "privatelink_vpc_endpoints" {
  source  = "cloudposse/vpc/aws//modules/vpc-endpoints"
  version = "2.1.0"

  enabled                 = local.privatelink_enabled
  vpc_id                  = module.vpc.vpc_id
  gateway_vpc_endpoints   = local.privatelink_gateway_endpoint_map
  interface_vpc_endpoints = local.privatelink_vpc_endpoint_map

  context = module.this.context
}

# ------------------------------------------------------------------- shield ---

data "aws_eip" "nat" {
  for_each  = local.nat_aws_shield_protection_enabled ? toset(module.subnets.nat_ips) : []
  public_ip = each.key
}

resource "aws_shield_protection" "nat" {
  for_each = local.nat_aws_shield_protection_enabled ? data.aws_eip.nat : {}

  name         = data.aws_eip.nat[each.key].id
  resource_arn = "arn:aws:ec2:${local.aws_region_name}:${local.aws_account_id}:eip-allocation/${data.aws_eip.nat[each.key].id}"
}

# ---------------------------------------------------------------- flow-logs ---

resource "aws_flow_log" "this" {
  count = local.vpc_flow_logs_enabled ? 1 : 0

  log_destination      = var.vpc_flow_logs_destination
  log_destination_type = lower(var.vpc_flow_logs_destination_type)
  traffic_type         = upper(var.vpc_flow_logs_traffic_type)
  vpc_id               = module.vpc.vpc_id

  tags = module.this.tags
}
