# alb.tf
module "alb" {
  source               = "../modules/alb"
  name                 = var.app_name
  env                  = var.env
  vpc_id               = module.network.vpc_id
  subnet_public_id     = module.network.subnet_public_id
  security_group_lb_id = module.sg.security_group_lb_id
}
