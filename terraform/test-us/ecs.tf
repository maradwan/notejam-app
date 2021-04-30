module "ecs" {
  source         = "../modules/ecs"
  name           = var.app_name
  app_count      = var.app_count
  env            = var.env
  aws_region     = var.aws_region
  app_env        = var.app_env
  app_image      = var.app_image
  app_port       = var.app_port
  fargate_cpu    = var.fargate_cpu
  fargate_memory = var.fargate_memory
  db_user        = ""
  db_password    = ""
  db_url         = ""
  #db_user                     = module.aurora.master_username
  #db_password                 = module.aurora.master_password
  #db_url                      = module.aurora.writer_endpoint
  subnet_private_id           = module.network.subnet_private_id
  security_group_ecs_tasks_id = module.sg.security_group_ecs_tasks_id
  ecs_task_execution_role     = module.roles.ecs_task_execution_role
  alb_target_group            = module.alb.alb_target_group

  depends_on = [module.network, module.alb, module.roles]
  #depends_on = [module.aurora, module.network, module.alb, module.roles]
}
