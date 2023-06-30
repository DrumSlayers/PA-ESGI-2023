// Crée un déploiement Kubernetes pour le site web de transexpress
resource "kubernetes_deployment" "transexpress-website" {
  metadata {
    name = "transexpress-website-deployment"
    labels = {
      app = "transexpress-website"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "transexpress-website"
      }
    }

    template {
      metadata {
        labels = {
          app = "transexpress-website"
        }
      }

      spec {
        container {
          name  = "transexpress-website"
          image = "058322885590.dkr.ecr.us-east-1.amazonaws.com/transexpress-website:latest"
          image_pull_policy = "Always"

          port {
            container_port = 80
          }
          resources {
            requests {
              cpu    = "200m"
              memory = "450Mi"
            }
            limits {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [
    aws_eks_node_group.eks-cluster,
    helm_release.cluster_autoscaler
  ]
}

resource "kubernetes_service" "transexpress-website" {
  metadata {
    name = "transexpress-website-service"
  }
  spec {
    selector = {
      app = "transexpress-website"
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment.transexpress-website]
}
