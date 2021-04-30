data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Code Commit repo

resource "aws_codecommit_repository" "source_repo" {
  repository_name = var.source_repo_name
  description     = "This is the app repository"
}


# Trigger role and event rule to trigger pipeline

resource "aws_iam_role" "trigger_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  path               = "/"
}

resource "aws_iam_policy" "trigger_policy" {
  description = "Policy to allow rule to invoke pipeline"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "codepipeline:StartPipelineExecution"
      ],
      "Effect": "Allow",
      "Resource": "${aws_codepipeline.pipeline.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "trigger-attach" {
  role       = aws_iam_role.trigger_role.name
  policy_arn = aws_iam_policy.trigger_policy.arn
}

resource "aws_cloudwatch_event_rule" "trigger_rule" {
  description   = "Trigger the pipeline on change to repo/branch"
  event_pattern = <<PATTERN
{
  "source": [ "aws.codecommit" ],
  "detail-type": [ "CodeCommit Repository State Change" ],
  "resources": [ "${aws_codecommit_repository.source_repo.arn}" ],
  "detail": {
    "event": [ "referenceCreated", "referenceUpdated" ],
    "referenceType": [ "branch" ],
    "referenceName": [ "${var.source_repo_branch}" ]
  }
}
PATTERN
  role_arn      = aws_iam_role.trigger_role.arn
  is_enabled    = true

}

resource "aws_cloudwatch_event_target" "target_pipeline" {
  rule      = aws_cloudwatch_event_rule.trigger_rule.name
  arn       = aws_codepipeline.pipeline.arn
  role_arn  = aws_iam_role.trigger_role.arn
  target_id = "${var.source_repo_name}-${var.source_repo_branch}-pipeline"
}

# ECR Repo

resource "aws_ecr_repository" "image_repo" {
  name                 = var.image_repo_name
  image_tag_mutability = "MUTABLE"
}

# Codebuild role

resource "aws_iam_role" "codebuild_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  path               = "/"
}

resource "aws_iam_policy" "codebuild_policy" {
  description = "Policy to allow codebuild to execute build spec"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents",
        "ecs:DescribeTaskDefinition", "ecr:GetAuthorizationToken"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.artifact_bucket.arn}/*",
                  "${aws_s3_bucket.corss_artifact_bucket.arn}/*"]
    },
    {
      "Action": [
        "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability", "ecr:PutImage",
        "ecr:InitiateLayerUpload", "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Effect": "Allow",
      "Resource": "${aws_ecr_repository.image_repo.arn}"
    },
    {
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild-attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

# Codepipeline role

resource "aws_iam_role" "codepipeline_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  path               = "/"
}

resource "aws_iam_policy" "codepipeline_policy" {
  description = "Policy to allow codepipeline to execute"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject",
        "s3:GetBucketVersioning"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.artifact_bucket.arn}/*",
                  "${aws_s3_bucket.corss_artifact_bucket.arn}/*"]
    },
    {
      "Action" : [
        "codebuild:StartBuild", "codebuild:BatchGetBuilds",
        "cloudformation:*",
        "iam:PassRole",
        "codecommit:CancelUploadArchive",
        "codecommit:GetBranch",
        "codecommit:GetCommit",
        "codecommit:GetUploadArchiveStatus",
        "codecommit:UploadArchive",
        "codedeploy:CreateDeployment",
        "codedeploy:GetApplicationRevision",
        "codedeploy:GetApplication",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:RegisterApplicationRevision"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

data "aws_iam_policy" "AWSCodeDeployRoleForECS" {
  arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

data "aws_iam_policy" "AmazonECS_FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonECS_FullAccess-attach-role" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = data.aws_iam_policy.AmazonECS_FullAccess.arn
}



resource "aws_iam_role_policy_attachment" "AWSCodeDeployRoleForECS-attach-role" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = data.aws_iam_policy.AWSCodeDeployRoleForECS.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline-attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

resource "aws_s3_bucket" "artifact_bucket" {
}

resource "aws_s3_bucket" "corss_artifact_bucket" {
  provider = aws.aws_backup_region
}


# Codebuild project

resource "aws_codebuild_project" "codebuild" {
  depends_on = [
    aws_codecommit_repository.source_repo,
    aws_ecr_repository.image_repo
  ]
  name         = "codebuild-${var.source_repo_name}-${var.source_repo_branch}"
  service_role = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.image_repo_name
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = <<BUILDSPEC

version: 0.2
runtime-versions:
  docker: 18
phases:
  install:
    runtime-versions:
      docker: 18
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
      - IMAGE_TAG=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - echo $IMAGE_TAG
      - REPOSITORY_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME
      - echo $REPOSITORY_URI
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - export taskDefinitionArn="arn:aws:ecs:${var.aws_backup_region}:$AWS_ACCOUNT_ID:task-definition/${var.app_name}-test-app-task"
      - export ContainerName=$(aws --region ${var.aws_backup_region} ecs describe-task-definition --task-definition ${var.app_name}-test-app-task | jq '.taskDefinition.containerDefinitions[0].name')
      - export ContainerPort=$(aws --region ${var.aws_backup_region} ecs describe-task-definition --task-definition ${var.app_name}-test-app-task | jq '.taskDefinition.containerDefinitions[0].portMappings[0].containerPort') 
      - envsubst < appspec_template.yaml > appspec-${var.aws_backup_region}-test.yaml
      - export taskDefinitionArn="arn:aws:ecs:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:task-definition/${var.app_name}-test-app-task"
      - export ContainerName=$(aws ecs describe-task-definition --task-definition ${var.app_name}-test-app-task | jq '.taskDefinition.containerDefinitions[0].name')
      - export ContainerPort=$(aws ecs describe-task-definition --task-definition ${var.app_name}-test-app-task | jq '.taskDefinition.containerDefinitions[0].portMappings[0].containerPort') 
      - envsubst < appspec_template.yaml > appspec-test.yaml
      - export taskDefinitionArn="arn:aws:ecs:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:task-definition/${var.app_name}-dev-app-task"
      - export ContainerName=$(aws ecs describe-task-definition --task-definition ${var.app_name}-dev-app-task | jq '.taskDefinition.containerDefinitions[0].name')
      - export ContainerPort=$(aws ecs describe-task-definition --task-definition ${var.app_name}-dev-app-task | jq '.taskDefinition.containerDefinitions[0].portMappings[0].containerPort') 
      - envsubst < appspec_template.yaml > appspec-dev.yaml
      - export taskDefinitionArn="arn:aws:ecs:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:task-definition/${var.app_name}-prod-app-task"
      - export ContainerName=$(aws ecs describe-task-definition --task-definition ${var.app_name}-prod-app-task | jq '.taskDefinition.containerDefinitions[0].name')
      - export ContainerPort=$(aws ecs describe-task-definition --task-definition ${var.app_name}-prod-app-task | jq '.taskDefinition.containerDefinitions[0].portMappings[0].containerPort') 
      - envsubst < appspec_template.yaml > appspec-prod.yaml
      - $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
      - docker run -t --rm $REPOSITORY_URI:$IMAGE_TAG tests.py
      - aws ecs describe-task-definition --task-definition ${var.app_name}-test-app-task | jq 'del(.taskDefinition.taskDefinitionArn)' | jq '.taskDefinition' | jq 'del(.revision)' | jq 'del(.requiresAttributes)' | jq '.containerDefinitions[0].image = ('\"$REPOSITORY_URI:$IMAGE_TAG\"')' > taskdef-test.json
      - aws ecs describe-task-definition --task-definition ${var.app_name}-dev-app-task | jq 'del(.taskDefinition.taskDefinitionArn)' | jq '.taskDefinition' | jq 'del(.revision)' | jq 'del(.requiresAttributes)' | jq '.containerDefinitions[0].image = ('\"$REPOSITORY_URI:$IMAGE_TAG\"')' > taskdef-dev.json
      - aws ecs describe-task-definition --task-definition ${var.app_name}-prod-app-task | jq 'del(.taskDefinition.taskDefinitionArn)' | jq '.taskDefinition' | jq 'del(.revision)' | jq 'del(.requiresAttributes)' | jq '.containerDefinitions[0].image = ('\"$REPOSITORY_URI:$IMAGE_TAG\"')' > taskdef-prod.json
      - aws --region ${var.aws_backup_region} ecs describe-task-definition --task-definition ${var.app_name}-test-app-task | jq 'del(.taskDefinition.taskDefinitionArn)' | jq '.taskDefinition' | jq 'del(.revision)' | jq 'del(.requiresAttributes)' | jq '.containerDefinitions[0].image = ('\"$REPOSITORY_URI:$IMAGE_TAG\"')' > taskdef-${var.aws_backup_region}-test.json

artifacts:
    files: 
      - appspec-test.yaml
      - appspec-dev.yaml
      - appspec-prod.yaml
      - taskdef-test.json
      - taskdef-dev.json
      - taskdef-prod.json
      - appspec-${var.aws_backup_region}-test.yaml
      - taskdef-${var.aws_backup_region}-test.json

BUILDSPEC
  }
}

# CodePipeline

resource "aws_codepipeline" "pipeline" {
  depends_on = [
    aws_codebuild_project.codebuild
  ]
  name     = "${var.source_repo_name}-${var.source_repo_branch}-Pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    region   = var.aws_region
    type     = "S3"
  }

  artifact_store {
    location = aws_s3_bucket.corss_artifact_bucket.bucket
    region   = var.aws_backup_region
    type     = "S3"
  }


  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeCommit"
      output_artifacts = ["SourceOutput"]
      run_order        = 1
      configuration = {
        RepositoryName       = var.source_repo_name
        BranchName           = var.source_repo_branch
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build-and-Tests"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild.id
      }
    }
  }

  stage {
    name = "Deploy-Test"

    action {



      category = "Deploy"
      configuration = {
        "ApplicationName"                = "${var.app_name}-test"
        "DeploymentGroupName"            = "${var.app_name}-test"
        "AppSpecTemplateArtifact"        = "BuildOutput"
        "TaskDefinitionTemplateArtifact" = "BuildOutput"
        "AppSpecTemplatePath"            = "appspec-test.yaml"
        "TaskDefinitionTemplatePath"     = "taskdef-test.json"
      }
      input_artifacts = [
        "BuildOutput",
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "CodeDeployToECS"
      region           = var.aws_region
      run_order        = 1
      version          = "1"
    }



    action {
      category = "Deploy"
      configuration = {
        "AppSpecTemplateArtifact"        = "BuildOutput"
        "AppSpecTemplatePath"            = "appspec-${var.aws_backup_region}-test.yaml"
        "ApplicationName"                = "notejam-${var.aws_backup_region}-test"
        "DeploymentGroupName"            = "notejam-${var.aws_backup_region}-test"
        "TaskDefinitionTemplateArtifact" = "BuildOutput"
        "TaskDefinitionTemplatePath"     = "taskdef-${var.aws_backup_region}-test.json"
      }
      input_artifacts = [
        "BuildOutput",
      ]
      name             = "Deploy-US"
      output_artifacts = []
      owner            = "AWS"
      provider         = "CodeDeployToECS"
      region           = var.aws_backup_region
      run_order        = 1
      version          = "1"
    }


  }



  stage {
    name = "Deploy-Development"

    action {

      category = "Deploy"
      configuration = {
        "ApplicationName"                = "${var.app_name}-dev"
        "DeploymentGroupName"            = "${var.app_name}-dev"
        "AppSpecTemplateArtifact"        = "BuildOutput"
        "TaskDefinitionTemplateArtifact" = "BuildOutput"
        "AppSpecTemplatePath"            = "appspec-dev.yaml"
        "TaskDefinitionTemplatePath"     = "taskdef-dev.json"
      }
      input_artifacts = [
        "BuildOutput",
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "CodeDeployToECS"
      region           = var.aws_region
      run_order        = 1
      version          = "1"
    }
  }

  stage {
    name = "Deploy-Production"

    action {
      category = "Approval"
      configuration = {
      }
      input_artifacts = [

      ]
      name      = "Approval"
      run_order = 1
      provider  = "Manual"
      owner     = "AWS"
      version   = "1"

    }
    action {


      category = "Deploy"
      configuration = {

        "ApplicationName"                = "${var.app_name}-prod"
        "DeploymentGroupName"            = "${var.app_name}-prod"
        "AppSpecTemplateArtifact"        = "BuildOutput"
        "TaskDefinitionTemplateArtifact" = "BuildOutput"
        "AppSpecTemplatePath"            = "appspec-prod.yaml"
        "TaskDefinitionTemplatePath"     = "taskdef-prod.json"
      }
      input_artifacts = [
        "BuildOutput",
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "CodeDeployToECS"
      region           = var.aws_region
      run_order        = 2
      version          = "1"
    }

  }
}