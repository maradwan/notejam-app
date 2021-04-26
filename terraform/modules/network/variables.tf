variable "cidr" {
  default = ""
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "eu-west-1"
}

variable "env" {}