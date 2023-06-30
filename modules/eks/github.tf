resource "github_actions_secret" "kubeconfig_secret" {
  repository       = "TransExpress-website"
  secret_name      = "KUBE_CONFIG"
  plaintext_value  = base64encode(yamlencode({
    apiVersion = "v1"
    clusters = [{
      cluster = {
        server    = data.aws_eks_cluster.cluster.endpoint
        certificate-authority-data = data.aws_eks_cluster.cluster.certificate_authority[0].data
      }
      name = "kubernetes"
    }]
    contexts = [{
      context = {
        cluster = "kubernetes"
        user    = "aws"
      }
      name = "aws"
    }]
    current-context = "aws"
    kind            = "Config"
    preferences = {}
    users = [{
      name = "aws"
      user = {
        exec = {
          apiVersion = "client.authentication.k8s.io/v1beta1"
          args       = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks-cluster.name]
          command    = "aws"
        }
      }
    }]
  }))
  depends_on = [
    aws_eks_node_group.eks-cluster,
    aws_eks_node_group.eks-cluster,
    helm_release.cluster_autoscaler,
    kubernetes_service.transexpress-website
  ]
}

resource "github_actions_secret" "AWS_ACCESS_KEY_ID_secret" {
  repository       = "TransExpress-website"
  secret_name      = "AWS_ACCESS_KEY_ID"
  plaintext_value  = var.aws_access_key_id
}

resource "github_actions_secret" "AWS_REGION_secret" {
  repository       = "TransExpress-website"
  secret_name      = "AWS_REGION"
  plaintext_value  = var.aws_region
}

resource "github_actions_secret" "AWS_SECRET_ACCESS_KEY_secret" {
  repository       = "TransExpress-website"
  secret_name      = "AWS_SECRET_ACCESS_KEY"
  plaintext_value  = var.aws_secret_access_key
}

resource "github_actions_secret" "AWS_SESSION_TOKEN_secret" {
  repository       = "TransExpress-website"
  secret_name      = "AWS_SESSION_TOKEN"
  plaintext_value  = var.aws_session_token
}