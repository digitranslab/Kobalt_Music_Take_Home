output "emr_check_arn" {
  value = aws_lambda_function.emr_check.arn
}

output "monitor_service_arn" {
  value = aws_lambda_function.monitor_service.arn
}

output "frontservice_arn" {
  value = aws_lambda_function.frontservice.arn
} 