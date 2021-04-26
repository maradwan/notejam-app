data "aws_vpc" "vpc" {
  id = var.vpc_id
}

#Database Aurora 
resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "tf-${var.name}-${var.env}"
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = var.master_password
  backup_retention_period = var.backup_retention_period
  vpc_security_group_ids  = [aws_security_group.aurora_security_group.id]
  apply_immediately       = var.apply_immediately
  db_subnet_group_name    = aws_db_subnet_group.main.id
  skip_final_snapshot     = true
}

resource "aws_db_subnet_group" "main" {
  name       = "tf-rds-${var.name}-${var.env}"
  subnet_ids = var.subnets

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  count                = var.cluster_size
  identifier           = "tf-rds-${var.name}-${var.env}"
  cluster_identifier   = aws_rds_cluster.aurora.id
  instance_class       = var.instance_class
  publicly_accessible  = var.publicly_accessible
  db_subnet_group_name = aws_db_subnet_group.main.id

  tags = {
    Name = "tf-rds-${var.name}-${var.env}"
  }
}