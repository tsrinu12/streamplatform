resource "aws_db_instance" "streamplatform" {
  identifier           = "streamplatform-${var.environment}"
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.medium"
  allocated_storage     = 20
  max_allocated_storage = 100
  db_name              = "streamplatform"
  username             = "streamadmin"
  password             = var.db_password
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = [var.rds_sg_id]
  skip_final_snapshot  = true
  multi_az             = true
  storage_type         = "gp3"
  performance_insights_enabled = true
}

output "rds_endpoint" {
  value = aws_db_instance.streamplatform.endpoint
}
