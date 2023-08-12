# Terraform Module: AWS VPC Network

This Terraform module deploys a complete Virtual Private Cloud (VPC) network on
AWS with sensible defaults. It creates a VPC, public and private subnets, a NAT
gateway, VPC flow logs, and optional VPC endpoints.

## Usage

```hcl
module "vpc_network" {
  source  = "cruxstack/vpc-network/aws"
  version = "x.x.x"

  vpc_ipv4_cidr             = "10.0.0.0/16"
  availability_zones        = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_flow_logs_destination = "your-flowlogs-bucket"
}
```

## Inputs

In addition to the variables documented below, this module includes several
other optional variables (e.g., `name`, `tags`, etc.) provided by the
`cloudposse/label/null` module. Please refer to its [documentation](https://registry.terraform.io/modules/cloudposse/label/null/latest)
for more details on these variables.

| Name                                | Description                                                                                                                      | Type         | Default   | Required |
|-------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|--------------|-----------|----------|
| `availability_zone_ids`             | List of AZ IDs for subnet creation. Overrides `availability_zones`.                                                              | list(string) | []        | No       |
| `availability_zones`                | List of Availability Zones (AZs) for subnet creation. Ignored if `availability_zone_ids` is set.                                 | list(string) | []        | No       |
| `aws_account_id`                    | AWS account ID.                                                                                                                  | string       | ""        | No       |
| `aws_region_name`                   | AWS Region.                                                                                                                      | string       | ""        | No       |
| `nat_aws_shield_protection_enabled` | Toggle for AWS Shield Advanced protection for NAT EIPs. An active AWS Shield Advanced subscription is required if set to 'true'. | bool         | false     | No       |
| `nat_instance_size`                 | Size of the NAT instance. Only used if `nat_type` is set to `instance`.                                                          | string       | "t3.nano" | No       |
| `nat_type`                          | Type of NAT to create. Can be `gateway` or `instance`.                                                                           | string       | "gateway" | No       |
| `private_subnets_extra_tags`        | Extra tags for NAT subnets.                                                                                                      | map(string)  | {}        | No       |
| `privatelink_gateway_endpoints`     | List of Gateway VPC Endpoints for the VPC. Can only be `dynamodb` and `s3`.                                                      | set(string)  | []        | No       |
| `privatelink_vpc_endpoints`         | List of Interface VPC Endpoints for the VPC.                                                                                     | set(string)  | []        | No       |
| `public_subnets_auto_assign_ip`     | Toggle for assigning a public IP address to instances in a public subnet.                                                        | bool         | true      | No       |
| `public_subnets_enabled`            | Toggle for creating public subnets. If false, public subnets won't be created.                                                   | bool         | true      | No       |
| `public_subnets_extra_tags`         | Extra tags for public subnets.                                                                                                   | map(string)  | {}        | No       |
| `subnet_ipv4_cidrs`                 | List of CIDRs for subnets. Must maintain order.                                                                                  | list(object) | []        | No       |
| `subnet_max_count`                  | Maximum number of subnets to deploy. `0` deploys a subnet for each availability zone.                                            | number       | 0         | No       |
| `vpc_flow_logs_destination`         | ARN of the logging destination.                                                                                                  | string       | ""        | No       |
| `vpc_flow_logs_destination_type`    | Type of the logging destination. Can be `cloud-watch-logs` or `s3`.                                                              | string       | "s3"      | No       |
| `vpc_flow_logs_enabled`             | Toggle for VPC Flow Logs.                                                                                                        | bool         | true      | No       |
| `vpc_flow_logs_traffic_type`        | Type of traffic to capture. Can be `ACCEPT`, `REJECT`, or `ALL`.                                                                 | string       | "ALL"     | No       |
| `vpc_ipv4_cidr`                     | Primary IPv4 CIDR block for the VPC.                                                                                             | string       | None      | Yes      |
| `vpc_ipv6_cidr_auto_assigned`       | Toggle for assigning AWS generated IPv6 CIDR block to the VPC.                                                                   | bool         | false     | No       |

## Outputs

| Name                            | Description                                                  |
|---------------------------------|--------------------------------------------------------------|
| `availability_zones`            | List of Availability Zones where subnets were created.       |
| `az_private_subnets_map`        | Map of AZ names to list of private subnet IDs in the AZs.    |
| `az_public_subnets_map`         | Map of AZ names to list of public subnet IDs in the AZs.     |
| `nat_eip_protections`           | List of AWS Shield Advanced Protections for NAT Elastic IPs. |
| `nat_gateway_public_ips`        | Public IPs of the NAT Gateways.                              |
| `nat_ids`                       | IDs of the NAT Gateways.                                     |
| `private_cidr_blocks`           | CIDRs of the private subnets.                                |
| `private_route_table_ids`       | IDs of the private subnet route tables.                      |
| `private_subnet_cidrs`          | CIDRs of the private subnets.                                |
| `private_subnet_ids`            | IDs of the private subnets.                                  |
| `public_route_table_ids`        | IDs of the public subnet route tables.                       |
| `public_subnet_cidrs`           | CIDRs of the public subnets.                                 |
| `public_subnet_ids`             | IDs of the public subnets.                                   |
| `vpc_default_network_acl_id`    | ID of the default network ACL created on VPC creation.       |
| `vpc_default_security_group_id` | ID of the default security group created on VPC creation.    |
| `vpc_id`                        | ID of the VPC.                                               |
| `vpc_ipv4_cidr`                 | CIDR of the VPC.                                             |

## Contributing

We welcome contributions to this project. For information on setting up a
development environment and how to make a contribution, see [CONTRIBUTING](./CONTRIBUTING.md)
documentation.
