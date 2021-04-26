# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "eu-west-1"
}

variable "env" {
  description = "The AWS environment"
  default     = "prod"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "vpc_cidr" {
  default = "172.19.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "maradwan/notejam:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 5000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 2
}

variable "app_env" {
  description = "Number of docker containers to run"
  default     = "production"
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "app_name" {
  description = "app name"
  default     = "notejam"
}

variable "cloudwatch_retention_in_days" {
  default = 30
}

variable "codedeploy_termination_wait_time_in_minutes" {
  default = "1"
}

variable "codedeploy_deployment_config_name" {
  default = "CodeDeployDefault.ECSLinear10PercentEvery1Minutes"
}

variable "auto_scaling_max_capacity" {
  default = "6"
}

variable "auto_scaling_min_capacity" {
  default = "2"
}

variable "aurora_master_username" {
  default = "db_user"
}

variable "aurora_instance_class" {
  default = "db.t3.small"
}

variable "aurora_publicly_accessible" {
  default = "true"
}

variable "aurora_cluster_size" {
  default = 1
}

variable "aurora_backtrack_window" {
  default = 24
}

variable "aurora_backup_retention_period" {
  default = 30
}

variable "aurora_apply_immediately" {
  default = false
}