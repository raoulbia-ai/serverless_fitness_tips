resource "aws_secretsmanager_secret" "openai" {
  name                    = "${var.environment}_secret"
  description             = "${var.environment} openai org and key"
  recovery_window_in_days = "7"
}

resource "aws_secretsmanager_secret_version" "openai" {
  secret_id = aws_secretsmanager_secret.openai.id
  secret_string = jsonencode(
    {
      openai_org = ""
      openai_key = ""
    }
  )
}