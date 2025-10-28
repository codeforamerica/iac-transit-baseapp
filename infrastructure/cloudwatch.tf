# KMS Key for CloudWatch Logs encryption
resource "aws_kms_key" "cloudwatch_logs" {
  description             = "KMS key for CloudWatch logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation    = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cloudwatch-logs-key"
  })
}

# KMS Alias for CloudWatch Logs
resource "aws_kms_alias" "cloudwatch_logs" {
  name          = "alias/${local.name_prefix}-cloudwatch-logs"
  target_key_id = aws_kms_key.cloudwatch_logs.key_id
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = 30
  kms_key_id       = aws_kms_key.cloudwatch_logs.arn

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-log-group"
  })
}
