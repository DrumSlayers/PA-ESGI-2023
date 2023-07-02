// This resource block is used to create the EKS cluster. 
// It uses the specified IAM role and subnets that were created previously.
resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.project_eks}-cluster"
  role_arn = data.aws_iam_role.existing.arn // The Amazon Resource Name (ARN) of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]  // The security groups associated with the cross-account elastic network interfaces that are used to allow communication between your worker nodes and the Kubernetes control plane
    subnet_ids              = flatten([aws_subnet.public[*].id, aws_subnet.private[*].id]) // The subnets for the VPC where your cluster is created
    endpoint_private_access = true // Enable private access to the Kubernetes API server
    endpoint_public_access  = true // Enable public access to the Kubernetes API server
    public_access_cidrs     = ["0.0.0.0/0"] // The CIDR blocks that are allowed to access the public endpoint of your cluster
  }

  // The types of logs from the control plane that should be sent to CloudWatch Logs
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  // The metadata to assign to the EKS cluster
  tags = merge(
    var.tags
  )
}

// This resource block is used to create the EKS node group. 
// Three node groups are created, each in a different private subnet.
resource "aws_eks_node_group" "eks-cluster" {
  cluster_name    = aws_eks_cluster.eks-cluster.name // The name of the EKS cluster
  node_group_name = var.project_eks // The name of the node group
  node_role_arn     = data.aws_iam_role.existing.arn // The Amazon Resource Name (ARN) of the IAM role that provides permissions for the EKS node group
  subnet_ids      = aws_subnet.private[*].id // The subnets where the node group is created
  
  // The scaling configuration details for the Auto Scaling group that is associated with your node group
  scaling_config {
    desired_size = var.scaling_config_desired_size
    max_size     = var.scaling_config_max_size
    min_size     = var.scaling_config_min_size
  }

  ami_type       = var.ami_type_eks // The AMI version of the EKS node group
  disk_size      = var.disk_size_eks_node // The size of the EBS volume that is attached to each worker node
  instance_types = [var.instance_types_eks_node] // The instance type for the EKS node group

  // The metadata to assign to the EKS node group
  tags = merge(
    {
      "k8s.io/cluster-autoscaler/enabled" = "true"
      "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks-cluster.name}" = "owned"
    },
    var.tags
  )

  // The dependencies for the EKS node group resource
  depends_on = [
    aws_eks_cluster.eks-cluster
  ]
}

// This resource block is used to create a Helm release
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler" // The name of the Helm release
  repository = "https://kubernetes.github.io/autoscaler" // The chart repository URL
  chart      = "cluster-autoscaler" // The name of the Helm chart
  version = "9.29.1" // The version of the Helm chart

  // The set values for the Helm release
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

  // The dependencies for the Helm release resource
  depends_on = [
    aws_eks_node_group.eks-cluster
  ]
}

// This resource block is used to create a DNS record in Cloudflare
resource "cloudflare_record" "eks_cname" {
  zone_id = var.cloudflare_zone_id // The Cloudflare zone ID
  name    = var.cloudflare_dns_entry_name // The DNS record name
  value   = "${kubernetes_service.transexpress-website.load_balancer_ingress[0].hostname}" // The DNS record value
  type    = "CNAME" // The DNS record type
  ttl     = 1 // The DNS record TTL (time to live)
  
  // The Cloudflare proxy status for the DNS record
  proxied = true

  // The dependencies for the Cloudflare DNS record resource
  depends_on = [
    aws_eks_node_group.eks-cluster,
    helm_release.cluster_autoscaler,
    kubernetes_service.transexpress-website
  ]
}