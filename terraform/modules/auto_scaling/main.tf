
resource "aws_appautoscaling_target" "target" {
  service_namespace = "ecs"
  resource_id        = "service/${var.ecs_cluter_name}/${var.ecs_cluster_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "up" {
  name              = "${var.name}-${var.env}-scale-up"
  service_namespace = "ecs"
  resource_id        = "service/${var.ecs_cluter_name}/${var.ecs_cluster_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "down" {
  name              = "${var.name}-${var.env}-scale-down"
  service_namespace = "ecs"
  resource_id        = "service/${var.ecs_cluter_name}/${var.ecs_cluster_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "${var.name}-${var.env}-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    ClusterName = var.ecs_cluter_name
    ServiceName = var.ecs_cluster_service_name
  }

  alarm_actions = [aws_appautoscaling_policy.up.arn]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "${var.name}-${var.env}-cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = var.ecs_cluter_name
    ServiceName = var.ecs_cluster_service_name
  }

  alarm_actions = [aws_appautoscaling_policy.down.arn]
}
