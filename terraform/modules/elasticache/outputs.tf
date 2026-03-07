output "primary_endpoint_address" {
  description = "Address of the endpoint for the primary node"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Address of the endpoint for the reader node"
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "replication_group_id" {
  description = "ID of the ElastiCache Replication Group"
  value       = aws_elasticache_replication_group.main.id
}

output "port" {
  description = "Port number the cache cluster accepts connections on"
  value       = aws_elasticache_replication_group.main.port
}

output "configuration_endpoint" {
  description = "Configuration endpoint to allow host discovery"
  value       = aws_elasticache_replication_group.main.configuration_endpoint_address
}
