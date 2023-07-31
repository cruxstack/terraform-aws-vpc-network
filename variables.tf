# ====================================================================== vpc ===

variable "vpc_ipv4_cidr" {
  type        = string
  description = "Primary IPv4 CIDR block for the VPC."
}

variable "vpc_ipv6_cidr_auto_assigned" {
  type        = bool
  description = "Toggle for assigning AWS generated IPv6 CIDR block to the VPC."
  default     = false
}

variable "availability_zones" {
  type        = list(string)
  description = <<-EOF
    List of Availability Zones (AZs) for subnet creation. Must be stable. Ignored if `availability_zone_ids` is set.
  EOF
  default     = []
}

variable "availability_zone_ids" {
  type        = list(string)
  description = "List of AZ IDs for subnet creation. Overrides `availability_zones`."
  default     = []
}

variable "subnet_max_count" {
  type        = number
  default     = 0
  description = "Maximum number of subnets to deploy. `0` deploys a subnet for each availability zone."
}

variable "subnet_ipv4_cidrs" {
  type = list(object({
    private = list(string)
    public  = list(string)
  }))
  description = "List of CIDRs for subnets. Must maintain order."
  default     = []
}

variable "public_subnets_enabled" {
  type        = bool
  description = "Toggle for creating public subnets. If false, public subnets won't be created."
  default     = true
}

variable "public_subnets_auto_assign_ip" {
  type        = bool
  default     = true
  description = "Toggle for assigning a public IP address to instances in a public subnet."
}

variable "public_subnets_extra_tags" {
  type        = map(string)
  description = "Extra tags for public subnets."
  default     = {}
}

variable "private_subnets_extra_tags" {
  type        = map(string)
  description = "Extra tags for NAT subnets."
  default     = {}
}

# ---------------------------------------------------------------------- nat ---

variable "nat_type" {
  type        = string
  description = "Type of NAT to create. Can be `gateway` or `instance`."
  default     = "gateway"

  validation {
    condition     = contains(["gateway", "instance"], lower(var.nat_type))
    error_message = "Must be either `gateway` or `instance`."
  }
}

variable "nat_instance_size" {
  type        = string
  description = "Size of the NAT instance. Only used if `nat_type` is set to `instance`."
  default     = "t3.nano"
}

variable "nat_aws_shield_protection_enabled" {
  type        = bool
  description = <<-EOF
    Toggle for AWS Shield Advanced protection for NAT EIPs. An active AWS Shield Advanced subscription is required if
    set to 'true'.
  EOF
  default     = false
}

# ---------------------------------------------------------------- flow-logs ---

variable "vpc_flow_logs_enabled" {
  type        = bool
  description = "Toggle for VPC Flow Logs."
  default     = true
}

variable "vpc_flow_logs_traffic_type" {
  type        = string
  description = "Type of traffic to capture. Can be `ACCEPT`, `REJECT`, or `ALL`."
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], upper(var.vpc_flow_logs_traffic_type))
    error_message = "Must be a comma-separated list of `ACCEPT`, `REJECT`, or `ALL`."
  }
}

variable "vpc_flow_logs_destination" {
  type        = string
  description = "ARN of the logging destination."
  default     = ""
}

variable "vpc_flow_logs_destination_type" {
  type        = string
  description = "Type of the logging destination. Can be `cloud-watch-logs` or `s3`."
  default     = "s3"

  validation {
    condition     = contains(["cloud-watch-logs", "s3"], lower(var.vpc_flow_logs_destination_type))
    error_message = "Must be either `cloud-watch-logs` or `s3`."
  }
}

# -------------------------------------------------------------- privatelink ---

variable "privatelink_gateway_endpoints" {
  type        = set(string)
  description = "List of Gateway VPC Endpoints for the VPC. Can only be `dynamodb` and `s3`."
  default     = []

  validation {
    condition     = alltrue([for x in var.privatelink_gateway_endpoints : contains(["dynamodb", "s3"], lower(x))])
    error_message = "Only valid values are `dynamodb` and `s3`."
  }
}

variable "privatelink_vpc_endpoints" {
  type        = set(string)
  description = "List of Interface VPC Endpoints for the VPC."
  default     = []
}

# ================================================================== context ===

variable "aws_region_name" {
  type        = string
  description = "AWS Region."
  default     = ""
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID."
  default     = ""
}
