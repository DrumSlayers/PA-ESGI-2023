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

  set {
    name  = "extraArgs.scale-down-delay-after-add"
    value = "1m" // Time the autoscaler cluster waits after adding a node before considering deleting nodes in minute
  }

  set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = "1m" // Time a node must be unused before being considered for deletion in minute
  }

  set {
    name  = "extraArgs.scale-down-utilization-threshold"
    value = "0.5" // This means a node is considered for removal when it's less than 50% utilized.
  }

  // The dependencies for the Helm release resource
  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_eks_node_group.eks-cluster
  ]
}