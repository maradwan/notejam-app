module "codedeploy" {
  source                           = "../modules/codedeploy"
  name                             = "${var.app_name}-${var.aws_region}"
  env                              = var.env
  deployment_config_name           = var.codedeploy_deployment_config_name
  termination_wait_time_in_minutes = var.codedeploy_termination_wait_time_in_minutes
  ecs_cluter_name                  = module.ecs.cluter_name
  ecs_cluster_service_name         = module.ecs.cluster_service_name
  alb_target_group_app_name        = module.alb.alb_target_group_app_name
  alb_target_group_app2_name       = module.alb.alb_target_group_app2_name
  alb_listener_front_end_arn       = module.alb.alb_listener_front_end_arn
}
