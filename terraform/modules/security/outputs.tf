output "security_group_lb_id" {
  # value = "aws_subnet.public.id"
  #value = "aws_nat_gateway.gw.subnet_id"
  value = [aws_security_group.lb.id]
  # value = ""
}

output "security_group_ecs_tasks_id" {
  value = [aws_security_group.ecs_tasks.id]
}
