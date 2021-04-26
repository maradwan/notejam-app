variable "name" {}
variable "vpc_id" {}
variable "env" {}
variable "database_name" {}
variable "master_username" {}
variable "master_password" {}
variable "backtrack_window" {}
variable "backup_retention_period" {}
variable "apply_immediately" {}

variable "allowed_cidr" {
  type        = list(any)
  default     = ["127.0.0.1/32"]
  description = "A list of Security Group ID's to allow access to."
}

variable "allowed_security_groups" {
  type        = list(any)
  default     = []
  description = "A list of Security Group ID's to allow access to."
}

variable "db_port" {
  default = 3306
}

variable "instance_class" {
  description = "Instance class to use when creating RDS cluster"
  default     = "db.t3.small"
}

variable "publicly_accessible" {
  description = "Should the instance get a public IP address?"
  default     = "false"
}

variable "cluster_size" {
  description = "Number of cluster instances to create"
}

variable "subnets" {
  description = "Subnets to use in creating RDS subnet group (must already exist)"
  type        = list(any)
}