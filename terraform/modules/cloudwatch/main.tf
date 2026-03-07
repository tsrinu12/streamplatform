# CloudWatch Module for StreamPlatform

resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/streamplatform/${var.environment}/application"
  retention_in_days = var.log_retention_days

  tags = var.common_tags
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "StreamPlatform-${var.environment}-Overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EKS", "cluster_failed_node_count", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EKS Cluster Health"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_id]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS CPU Utilization"
        }
      }
    ]
  })
}

# Metric Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "HighCPU-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    ClusterName = var.cluster_name
  }
}
