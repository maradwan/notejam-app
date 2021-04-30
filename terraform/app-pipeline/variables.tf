variable "aws_region" {
  description = "Source repo name"
  type        = string
  default     = "eu-west-1"
}

variable "aws_backup_region" {
  description = "Source repo name"
  type        = string
  default     = "us-east-2"
}

variable "app_name" {
  description = "Source repo name"
  type        = string
  default     = "notejam"
}

variable "source_repo_name" {
  description = "Source repo name"
  type        = string
  default     = "notejam"
}

variable "source_repo_branch" {
  description = "Source repo branch"
  type        = string
  default     = "master"
}

variable "image_repo_name" {
  description = "Image repo name"
  type        = string
  default     = "notejam"
}
