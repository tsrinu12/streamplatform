resource "aws_docdb_cluster" "main" {
  cluster_identifier      = var.cluster_identifier
  engine                  = "docdb"
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  db_subnet_group_name    = aws_docdb_subnet_group.main.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]
  
  tags = merge(
    var.tags,
    {
      Name = var.cluster_identifier
    }
  )
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "${var.cluster_identifier}-${count.index}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.instance_class
  
  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_identifier}-${count.index}"
    }
  )
}

resource "aws_docdb_subnet_group" "main" {
  name       = "${var.cluster_identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  
  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_identifier}-subnet-group"
    }
  )
}
