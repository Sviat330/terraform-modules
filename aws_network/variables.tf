variable "vpc_cidr" {
  description = "Vpc cidr block"
  default     = "10.0.0.0/16"
}
data "aws_region" "current" {
}
variable "env_code" {
  description = "Environment Code (dev|test|stg|prod) For development, test, staging, production."
  default     = "test"
}
data "aws_availability_zones" "available" {
  state = "available"
}
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default = [
    "10.0.11.0/24",
    "10.0.21.0/24"
  ]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default = [
    "10.0.12.0/24",
    "10.0.22.0/24"
  ]
}

