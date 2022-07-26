# ------------------------------------------------------------------------------
# The AWS Lambda function that is used to publish egress IP addresses.
# The ZIP file is created with:
# http://github.com/cisagov/publish-egress-ip-lambda
# ------------------------------------------------------------------------------

resource "aws_lambda_function" "publish_egress_ip" {
  provider = aws.deploy

  description      = var.lambda_function_description
  filename         = var.lambda_zip_filename
  function_name    = var.lambda_function_name
  handler          = "lambda_handler.handler"
  memory_size      = 128
  role             = aws_iam_role.lambdaexecution_role.arn
  runtime          = "python3.9"
  source_code_hash = filebase64sha256(var.lambda_zip_filename)
  timeout          = 600
}

# The CloudWatch log group for the Lambda function
resource "aws_cloudwatch_log_group" "lambda_logs" {
  provider = aws.deploy

  name              = format("/aws/lambda/%s", var.lambda_function_name)
  retention_in_days = 30
}

# Schedule the Lambda function to run every X minutes
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  provider = aws.deploy

  description         = format("Executes %s Lambda every %d minutes", var.lambda_function_name, var.lambda_schedule_interval)
  name                = format("%s-every-%d-minutes", var.lambda_function_name, var.lambda_schedule_interval)
  schedule_expression = format("rate(%d minutes)", var.lambda_schedule_interval)
}

resource "aws_cloudwatch_event_target" "lambda_schedule" {
  provider = aws.deploy

  arn       = aws_lambda_function.publish_egress_ip.arn
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda"

  input = jsonencode({
    account_ids        = tolist(local.accounts_to_check)
    application_tag    = var.application_tag
    bucket_name        = var.bucket_name
    domain             = var.domain
    ec2_read_role_name = var.ec2_read_role_name
    file_configs       = var.file_configs
    file_header        = var.file_header
    publish_egress_tag = var.publish_egress_tag
    region_filters     = var.region_filters
    task               = "publish"
  })
}

# Allow the CloudWatch event to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  provider = aws.deploy

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.publish_egress_ip.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
  statement_id  = "AllowExecutionFromCloudWatch"
}
