// EKS Cluster configuration
// Crée un cluster EKS avec le rôle IAM spécifié et les sous-réseaux créés précédemment
resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.project_eks}-cluster"
  role_arn = data.aws_iam_role.existing.arn

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
    subnet_ids              = flatten([aws_subnet.public[*].id, aws_subnet.private[*].id])
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }
  
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

    tags = merge(
    var.tags
  )
}


// EKS Node groupe configuration
// Crée 3 groupes de nœuds EKS, chacun dans un sous-réseau privé différent
resource "aws_eks_node_group" "eks-cluster" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = var.project_eks
  node_role_arn     = data.aws_iam_role.existing.arn
  subnet_ids      = aws_subnet.private[*].id
  
  scaling_config {
    desired_size = 3
    max_size     = 8
    min_size     = 3
  }
  

  ami_type       = "AL2_x86_64"
  disk_size      = 20
  instance_types = ["t2.micro"]

  tags = merge(
    {
      "k8s.io/cluster-autoscaler/enabled" = "true"
      "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks-cluster.name}" = "owned"
    },
    var.tags
  )

  depends_on = [
    aws_eks_cluster.eks-cluster
  ]
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version = "9.29.1"

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.eks-cluster.name
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.create"
    value = "true"
  }
  depends_on = [
    aws_eks_node_group.eks-cluster
  ]
}

resource "cloudflare_record" "eks_cname" {
  zone_id = var.cloudflare_zone_id
  name    = "eks"
  value   = "${kubernetes_service.transexpress-website.load_balancer_ingress[0].hostname}" 
  type    = "CNAME"
  ttl     = 1
  proxied = true
  depends_on = [
    aws_eks_node_group.eks-cluster,
    aws_eks_node_group.eks-cluster,
    helm_release.cluster_autoscaler,
    kubernetes_service.transexpress-website
  ]
}



