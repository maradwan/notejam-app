
output "source_repo_clone_url_http" {
  value = aws_codecommit_repository.source_repo.clone_url_http
}

output "source_repo_clone_url_ssh" {
  value = aws_codecommit_repository.source_repo.clone_url_ssh
}

output "image_repo_url" {
  value = aws_ecr_repository.image_repo.repository_url
}

output "image_repo_arn" {
  value = aws_ecr_repository.image_repo.arn
}

output "pipeline_url" {
  value = "https://console.aws.amazon.com/codepipeline/home?region=${data.aws_region.current.name}#/view/${aws_codepipeline.pipeline.id}"
}
