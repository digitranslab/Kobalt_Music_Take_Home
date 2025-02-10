provider "aws" {
  region = var.region
}

module "iam" {
  source = "./iam"
}

module "lambda" {
  source = "./lambda"
  emr_check_filename = "../build/lambda/check_service.zip"
  monitor_service_filename = "../build/lambda/monitor_service.zip"
  frontservice_filename = "../build/lambda/front_service.zip"
  lambda_role_arn = module.iam.lambda_role_arn
  region = var.region
  aws_account_number = var.aws_account_number
  lambda_layer_arn = "arn:aws:lambda:eu-west-1:017000801446:layer:AWSLambdaPowertoolsPythonV2:78"
}

# module "ecs" {
#   source = "./ecs"
#   frontend_image = "dockerhub-username/frontend:latest"
#   subnets = [aws_subnet.public.id]
#   security_groups = [aws_security_group.allow_http.id]
# }
