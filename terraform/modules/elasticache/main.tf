resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = var.replication_group_id
  replication_group_description = var.replication_group_description
  engine                     = "redis"
  engine_version             = var.engine_version
  node_type                  = var.node_type
  number_cache_clusters      = var.number_cache_clusters
  port                       = var.port
  parameter_group_name       = aws_elasticache_parameter_group.main.name
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = var.security_group_ids
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = var.snapshot_window
  maintenance_window         = var.maintenance_window
  
  tags = merge(
    var.tags,
    {
      Name = var.replication_group_id
    }
  )
}

resource "aws_elasticache_parameter_group" "main" {
  name   = "${var.replication_group_id}-params"
  family = var.parameter_group_family
  
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
  
  tags = var.tags
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.replication_group_id}-subnet-group"
  subnet_ids = var.subnet_ids
  
  tags = merge(
    var.tags,
    {
      Name = "${var.replication_group_id}-subnet-group"
    }
  )
}
