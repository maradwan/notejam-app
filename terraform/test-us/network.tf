module "network" {
  source   = "../modules/network"
  cidr     = var.vpc_cidr
  az_count = var.az_count
  env      = var.env
}

