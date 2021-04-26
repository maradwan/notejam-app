output "alb_target_group" {
  value = aws_alb_target_group.app.id
}

output "alb_target_group_app_name" {
  value = aws_alb_target_group.app.name
}

output "alb_target_group_app2_name" {
  value = aws_alb_target_group.app2.name
}

output "alb_listener_front_end_arn" {
  value = aws_alb_listener.front_end.id
}