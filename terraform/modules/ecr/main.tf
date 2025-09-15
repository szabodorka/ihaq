# resource "aws_ecr_repository" "backend" {
#   name                 = "ihaq-backend"
#   image_tag_mutability = "MUTABLE"
#   force_delete         = true

#   image_scanning_configuration {
#     scan_on_push = true
#     }

#   tags = {
#     Name = "ihaq-backend"
#     }
# }

# resource "aws_ecr_repository" "frontend" {
#   name                 = "ihaq-frontend"
#   image_tag_mutability = "MUTABLE"
#   force_delete         = true

#   image_scanning_configuration {
#     scan_on_push = true
#     }

#   tags = {
#     Name = "ihaq-frontend"
#     }
# }

resource "aws_ecr_repository" "ihaq" {
  name                 = "ihaq"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "ihaq-ecr"
  }
}

resource "terraform_data" "push_images" {
  depends_on = [
    aws_ecr_repository.ihaq
    ]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command = <<-EOT
      # Login to ECR
      docker logout
      aws ecr get-login-password --region eu-central-1 --profile default | docker login --username AWS --password-stdin ${aws_ecr_repository.ihaq.repository_url}

      # Build and push backend image
      cd .././backend
      docker build -t backend:latest .
      docker tag backend:latest ${aws_ecr_repository.ihaq.repository_url}:backend
      docker push ${aws_ecr_repository.ihaq.repository_url}:backend

      # Build and push frontend image
      cd .././frontend
      docker build -t frontend:latest .
      docker tag frontend:latest ${aws_ecr_repository.ihaq.repository_url}:frontend
      docker push ${aws_ecr_repository.ihaq.repository_url}:frontend
    EOT
  }
}