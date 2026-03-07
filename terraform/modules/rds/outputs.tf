output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.streamplatform.endpoint
}

output "rds_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.streamplatform.address
}

output "rds_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.streamplatform.port
}
