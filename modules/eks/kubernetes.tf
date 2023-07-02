// This resource block is used to create a Kubernetes deployment for the Transexpress website.
resource "kubernetes_deployment" "transexpress-website" {
  metadata {
    name = "transexpress-website-deployment" // The name of the Kubernetes deployment.
    
    // The labels to apply to the Kubernetes deployment.
    labels = {
      app = "transexpress-website"
    }
  }

  spec {
    replicas = 2 // The number of desired replicas of this deployment.

    // The label selector for the pods to be managed by this deployment.
    selector {
      match_labels = {
        app = "transexpress-website"
      }
    }

    template {
      metadata {
        // The labels to apply to the pods created by this deployment.
        labels = {
          app = "transexpress-website"
        }
      }

      spec {
        container {
          name  = "transexpress-website" // The name of the container within the pod.
          image = "058322885590.dkr.ecr.us-east-1.amazonaws.com/transexpress-website:latest" // The image to be used for the container.
          image_pull_policy = "Always" // The image pull policy for the container.

          port {
            container_port = 80 // The port to expose on the container.
          }
          
          resources {
            // The requested CPU and memory resources for the container.
            requests {
              cpu    = "200m"
              memory = "450Mi"
            }
            
            // The limit on the CPU and memory resources for the container.
            limits {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }

  // The dependencies for the Kubernetes deployment resource.
  depends_on = [
    aws_eks_node_group.eks-cluster,
    helm_release.cluster_autoscaler
  ]
}

// This resource block is used to create a Kubernetes service for the Transexpress website.
resource "kubernetes_service" "transexpress-website" {
  metadata {
    name = "transexpress-website-service" // The name of the Kubernetes service.
  }
  spec {
    // The selector for the pods that this service should manage.
    selector = {
      app = "transexpress-website"
    }
    port {
      port        = 80 // The port that this service should expose.
      target_port = 80 // The port on the target pods that this service should send traffic to.
    }
    type = "LoadBalancer" // The type of the service. "LoadBalancer" means that the service will be exposed to the internet.
  }

  // The dependencies for the Kubernetes service resource.
  depends_on = [kubernetes_deployment.transexpress-website]
}
