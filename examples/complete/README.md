# Example: Complete

This example provides a complete use case scenario for the VPC module. It
creates a Virtual Private Cloud (VPC) with a specific IP CIDR range, NAT type,
and availability zones.

## Usage

To run this example, run as-is or provide your own values for the following
variables in a `.terraform.tfvars` file:

```hcl
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_ipv4_cidr      = "10.0.0.0/16"
nat_type           = "instance"
```

## Inputs

| Name                 | Description                                              | Type         | Default                                      | Required |
|----------------------|----------------------------------------------------------|--------------|----------------------------------------------|:--------:|
| `availability_zones` | A list of availability zones in which to create the VPC. | list(string) | `["us-east-1a", "us-east-1b", "us-east-1c"]` |    no    |
| `vpc_ipv4_cidr`      | The IPv4 network range for the VPC, in CIDR notation.    | string       | `"10.0.0.0/16"`                              |    no    |
| `nat_type`           | The type of NAT device to create.                        | string       | `"instance"`                                 |    no    |

## Outputs

_This module does not define any outputs._
