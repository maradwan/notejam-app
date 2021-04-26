# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-${var.env}-cluster"
}

data "template_file" "app" {
  template = file("./templates/ecs/app.json.tpl")

  vars = {
    app_name       = var.name
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
    env            = var.env
    app_env        = var.app_env
    db_user        = var.db_user
    db_password    = var.db_password
    db_url         = var.db_url
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name}-${var.env}-app-task"
  execution_role_arn       = var.ecs_task_execution_role
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.app.rendered

  lifecycle {
    ignore_changes = [
      container_definitions
    ]
  }
}

resource "aws_ecs_service" "main" {
  name            = "${var.name}-${var.env}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  lifecycle {
    ignore_changes = [
      deployment_controller,
      desired_count,
      load_balancer,
      task_definition,
    ]
  }

  network_configuration {
    security_groups  = var.security_group_ecs_tasks_id
    subnets          = var.subnet_private_id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_target_group
    container_name   = "${var.name}-${var.env}"
    container_port   = var.app_port
  }

}