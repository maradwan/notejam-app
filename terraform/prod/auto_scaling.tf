
module "ecs_auto_scaling" {
  source                   = "../modules/auto_scaling"
  name                     = var.app_name
  env                      = var.env
  max_capacity             = var.auto_scaling_max_capacity
  min_capacity             = var.auto_scaling_min_capacity
  ecs_cluter_name          = module.ecs.cluter_name
  ecs_cluster_service_name = module.ecs.cluster_service_name
}
