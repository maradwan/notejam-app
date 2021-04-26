module "cloudwatch_log_group" {
  source            = "../modules/cloudwatch_logs"
  name              = var.app_name
  env               = var.env
  retention_in_days = var.cloudwatch_retention_in_days
}
