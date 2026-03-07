# Secrets Manager Module for StreamPlatform

resource "aws_secretsmanager_secret" "this" {
  name        = "${var.environment}/${var.secret_name}"
  description = var.description
  kms_key_id  = var.kms_key_id

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(var.secret_values)
}

# Secret Policy for Application Access
resource "aws_iam_policy" "secret_access" {
  name        = "SecretAccess-${var.secret_name}-${var.environment}"
  description = "Access to ${var.secret_name} in ${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Effect   = "Allow"
      Resource = aws_secretsmanager_secret.this.arn
    }]
  })
}
