# ====================================================================== vpc ===

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the VPC."
}

output "vpc_ipv4_cidr" {
  value       = module.vpc.vpc_cidr_block
  description = "CIDR of the VPC."
}

output "availability_zones" {
  description = <<-EOF
    List of Availability Zones where subnets were created.
  EOF
  value       = module.subnets.availability_zones
}

output "az_private_subnets_map" {
  description = <<-EOF
    Map of AZ names to list of private subnet IDs in the AZs.
  EOF
  value       = module.subnets.az_private_subnets_map
}

output "az_public_subnets_map" {
  description = <<-EOF
    Map of AZ names to list of public subnet IDs in the AZs.
  EOF
  value       = module.subnets.az_public_subnets_map
}

output "public_subnet_ids" {
  value       = module.subnets.public_subnet_ids
  description = "IDs of the public subnets."
}

output "public_subnet_cidrs" {
  value       = module.subnets.public_subnet_cidrs
  description = "CIDRs of the public subnets."
}

output "private_subnet_ids" {
  value       = module.subnets.private_subnet_ids
  description = "IDs of the private subnets."
}

output "private_subnet_cidrs" {
  value       = module.subnets.private_subnet_cidrs
  description = "CIDRs of the private subnets."
}

output "private_route_table_ids" {
  value       = module.subnets.private_route_table_ids
  description = "IDs of the private subnet route tables."
}

output "public_route_table_ids" {
  value       = module.subnets.public_route_table_ids
  description = "IDs of the public subnet route tables."
}

# ----------------------------------------------------------------- defaults ---

output "vpc_default_network_acl_id" {
  value       = module.vpc.vpc_default_network_acl_id
  description = "ID of the default network ACL created on VPC creation."
}

output "vpc_default_security_group_id" {
  value       = module.vpc.vpc_default_security_group_id
  description = "ID of the default security group created on VPC creation."
}

# ---------------------------------------------------------------------- nat ---

output "nat_ids" {
  value       = coalescelist(module.subnets.nat_gateway_ids, module.subnets.nat_instance_ids)
  description = "IDs of the NAT Gateways."
}

output "nat_gateway_public_ips" {
  value       = module.subnets.nat_gateway_public_ips
  description = "Public IPs of the NAT Gateways."
}

output "nat_eip_protections" {
  description = "List of AWS Shield Advanced Protections for NAT Elastic IPs."
  value       = aws_shield_protection.nat
}

# -------------------------------------------------------------- privatelink ---

output "privatelink_vpc_endpoints" {
  description = <<-EOF
    List of Interface VPC Endpoints in this VPC.
  EOF
  value       = try(module.privatelink_vpc_endpoints[0].interface_vpc_endpoints, [])
}
