# CodeDeploy

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
# CodeDeploy role

resource "aws_iam_role" "codedeploy_role" {
  name               = "${var.name}-${var.env}-codedeploy-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  path               = "/"
}


data "aws_iam_policy" "AWSCodeDeployRoleForECS" {
  arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}


resource "aws_iam_role_policy_attachment" "AWSCodeDeployRoleForECS-attach-role" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = data.aws_iam_policy.AWSCodeDeployRoleForECS.arn
}


resource "aws_codedeploy_app" "app_deploy" {
  compute_platform = "ECS"
  name             = "${var.name}-${var.env}"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name               = aws_codedeploy_app.app_deploy.name
  deployment_config_name = var.deployment_config_name
  deployment_group_name  = "${var.name}-${var.env}"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {

    cluster_name = var.ecs_cluter_name
    service_name = var.ecs_cluster_service_name

  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb_listener_front_end_arn]
      }

      target_group {
        name = var.alb_target_group_app_name
      }

      target_group {
        name = var.alb_target_group_app2_name

      }
    }
  }
}
