resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/ecs/${var.env}/${var.name}"
  retention_in_days = var.retention_in_days

  tags = {
    Name = "${var.name}-${var.env}-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "app_log_stream" {
  name           = "${var.name}-${var.env}-log-stream"
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
}

