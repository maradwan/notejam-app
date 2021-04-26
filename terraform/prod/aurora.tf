resource "random_string" "aurora-master-password" {
  length           = 10
  special          = false
  override_special = "/@\" "
}

module "aurora" {
  source                  = "../modules/aurora"
  name                    = "aurora-cluster-${var.app_name}"
  master_username         = var.aurora_master_username
  master_password         = random_string.aurora-master-password.result
  env                     = var.env
  subnets                 = module.network.subnet_public_id
  instance_class          = var.aurora_instance_class
  publicly_accessible     = var.aurora_publicly_accessible
  vpc_id                  = module.network.vpc_id
  cluster_size            = var.aurora_cluster_size
  allowed_cidr            = [var.vpc_cidr]
  database_name           = var.app_name
  backtrack_window        = var.aurora_backtrack_window
  backup_retention_period = var.aurora_backup_retention_period
  apply_immediately       = var.aurora_apply_immediately
}