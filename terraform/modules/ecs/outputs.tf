output "cluter_name" {
  value = aws_ecs_cluster.main.name
}

output "cluster_service_name" {
  value = aws_ecs_service.main.name
}