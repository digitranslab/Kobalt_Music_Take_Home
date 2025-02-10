variable "emr_check_filename" {}
variable "monitor_service_filename" {}
variable "frontservice_filename" {}
variable "lambda_role_arn" {}
variable "region" {}
variable "aws_account_number" {}

variable "lambda_layer_arn" {
  description = "The ARN of the Lambda layer to attach"
}