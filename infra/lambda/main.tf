resource "aws_lambda_function" "emr_check" {
  filename         = var.emr_check_filename
  function_name    = "emr_check_function"
  role             = var.lambda_role_arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.9"
  timeout          = 120  # Adjust based on expected execution time
  memory_size      = 256 # Adjust based on resource needs
  source_code_hash = filebase64sha256(var.emr_check_filename)

  environment {
    variables = {
      REGION             = var.region
      AWS_ACCOUNT_NUMBER = var.aws_account_number
      SNS_TOPIC_ARN      = var.sns_topic_arn  s
    }
  }

  layers = [var.lambda_layer_arn]
}

resource "aws_lambda_function" "monitor_service" {
  filename         = var.monitor_service_filename
  function_name    = "monitor_service_function"
  role             = var.lambda_role_arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.9"
  timeout          = 240  # Adjust based on expected execution time
  memory_size      = 256 # Adjust based on resource needs
  source_code_hash = filebase64sha256(var.monitor_service_filename)

  environment {
    variables = {
      REGION             = var.region
      AWS_ACCOUNT_NUMBER = var.aws_account_number
    }
  }

  layers = [var.lambda_layer_arn]
}

resource "aws_lambda_function" "frontservice" {
  filename         = var.frontservice_filename
  function_name    = "frontservice_function"
  role             = var.lambda_role_arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.9"
  timeout          = 120  # Adjust based on expected execution time
  memory_size      = 256 # Adjust based on resource needs
  source_code_hash = filebase64sha256(var.frontservice_filename)

  environment {
    variables = {
      REGION = var.region
    }
  }

  layers = [var.lambda_layer_arn]
}

resource "aws_cloudwatch_event_rule" "daily_check" {
  name                = "daily_temp_resource_check"
  schedule_expression = "cron(0 18 * * ? *)"  # Every day at 6pm
}

resource "aws_cloudwatch_event_target" "lambda_target_check" {
  rule      = aws_cloudwatch_event_rule.daily_check.name
  target_id = "emr_check"
  arn       = aws_lambda_function.emr_check.arn
}

resource "aws_sns_topic" "temp_resource_alerts" {
  name = "temp-resource-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.temp_resource_alerts.arn
  protocol  = "email"
  endpoint  = "example@example.com"  # Replace with your email
}

resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "LambdaErrorAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.temp_resource_alerts.arn]
  dimensions = {
    FunctionName = aws_lambda_function.emr_check.function_name
  }
} 