variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_ipv4_cidr" {
  type    = list(string)
  default = "10.0.0.0/16"
}

variable "nat_type" {
  type    = list(string)
  default = "instance"
}
