# Secrets Manager Secret
resource "aws_secretsmanager_secret" "main" {
  name                    = var.secrets_manager_secret_name
  description             = "Database credentials for Todo App"
  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-secrets"
  })
}

# Secrets Manager Secret Version
resource "aws_secretsmanager_secret_version" "main" {
  secret_id = aws_secretsmanager_secret.main.id
  secret_string = jsonencode({
    db_host     = aws_db_instance.main.endpoint
    db_port     = aws_db_instance.main.port
    db_name     = aws_db_instance.main.db_name
    db_user     = aws_db_instance.main.username
    db_password = aws_db_instance.main.password
  })
}
