[
  {
    "name": "${app_name}-${env}",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "environment":[
            {
                "name":  "ENVIRONMENT",
                "value": "${app_env}"
            },
            {
                "name": "DB_USER",
                "value": "${db_user}"
            },
            {
                "name": "DB_PASSWORD",
                "value": "${db_password}"
            },
            {
                "name": "DB_URL",
                "value": "${db_url}"
            }
    ],
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${env}/${app_name}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ]
  }
]
