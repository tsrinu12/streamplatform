output "cluster_endpoint" {
  description = "The endpoint for the DocumentDB cluster"
  value       = aws_docdb_cluster.main.endpoint
}

output "cluster_reader_endpoint" {
  description = "The reader endpoint for the DocumentDB cluster"
  value       = aws_docdb_cluster.main.reader_endpoint
}

output "cluster_id" {
  description = "The DocumentDB cluster identifier"
  value       = aws_docdb_cluster.main.id
}

output "cluster_arn" {
  description = "The ARN of the DocumentDB cluster"
  value       = aws_docdb_cluster.main.arn
}

output "cluster_port" {
  description = "The port on which the DB accepts connections"
  value       = aws_docdb_cluster.main.port
}
