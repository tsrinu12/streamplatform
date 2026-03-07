resource "aws_ecr_repository" "services" {
  for_each = toset(["auth-service", "video-service", "ai-service", "reward-service", "transcode-worker", "notification-service", "frontend"])
  
  name                 = "streamplatform/${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}

output "repository_urls" {
  value = { for k, v in aws_ecr_repository.services : k => v.repository_url }
}
