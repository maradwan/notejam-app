module "roles" {
  source = "../modules/roles"
  name   = "${var.app_name}-${var.aws_region}"
  env    = var.env
}
