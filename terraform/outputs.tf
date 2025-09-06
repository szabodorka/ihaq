output "eks_cluster_name" {
    value = module.eks.cluster_name
}

output "rds_endpoint" {
    value = module.rds.rds_endpoint
}

output "kubeconfig_command" {
    value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region eu-central-1"
}

output "openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}