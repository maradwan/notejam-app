*****************************************************************************
AWS ECS Fargate, CodeCommit, CodeDeploy, CodePipeline and Terraform  
*****************************************************************************

## Requirements

* Use Terraform version 12<= <https://www.terraform.io/downloads.html>
* aws configure <https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html>

### Steps

Clone the project

    $ git clone git@github.com:maradwan/notejam-app.git YOUR_PROJECT_DIR/

1- Build the environments testing, development and production
* To build testing environment

		$ cd YOUR_PROJECT_DIR/terraform/test
		$ terraform init
		$ terraform apply -auto-approve
		
* To build development environment

		$ cd YOUR_PROJECT_DIR/terraform/dev
		$ terraform init
		$ terraform apply -auto-approve

* To build production environment

		$ cd YOUR_PROJECT_DIR/terraform/dev
		$ terraform init
		$ terraform apply -auto-approve

2- After that we need to build the pipeline 

		$ cd YOUR_PROJECT_DIR/terraform/app-pipeline/
		$ terraform init
		$ terraform apply -auto-approve
		
3- Then clone the new repository that has been created on codecommit and copy the app to the cloned folder
* Add your ssh key to your IAM <https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-unixes.html>

		$ cd YOUR_PROJECT_DIR
		$ git clone ssh://git-codecommit.eu-west-1.amazonaws.com/v1/repos/notejam
		$ cd notejam	
		$ cp -r ../app/* .
		$ git add . && git commit -m "Adding the project" && git push
		


Deployment Strategy:

  * on testing environment: 

		blue/green ECSAllAtOnce

  * on development environment: 

		blue/green ECSLinear10PercentEvery1Minutes

  * on production environment: 

		blue/green ECSLinear10PercentEvery1Minutes


		
		
If you would like to deploy to multi region , copy the environment dev,test and prod and change the region name from variables.tf also you need to add a stage in app-pipeline as I did for test-us. 

* To add monitoring and logs we need to create elasticsearch subscription filter to cloudwatch <https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_ES_Stream.html>