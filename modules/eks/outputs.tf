output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = aws_eks_cluster.eks-cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster."
  value       = data.aws_iam_role.existing.name
}

output "cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

output "lb_address" {
  description = "The address of the load balancer"
  value       = kubernetes_service.transexpress-website.load_balancer_ingress[0].hostname
}
