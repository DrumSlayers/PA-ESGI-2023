// This resource block is used to create a Kubernetes deployment for the Transexpress website.
resource "kubernetes_deployment" "transexpress-website" {
  metadata {
    name = var.kube_deploy_name // The name of the Kubernetes deployment.
    
    // The labels to apply to the Kubernetes deployment.
    labels = {
      app = var.kube_deploy_label
    }
  }

  spec {
    replicas = var.kube_deploy_replicas // The number of desired replicas of this deployment.

    // The label selector for the pods to be managed by this deployment.
    selector {
      match_labels = {
        app = var.kube_deploy_label
      }
    }

    template {
      metadata {
        // The labels to apply to the pods created by this deployment.
        labels = {
          app = var.kube_deploy_label
        }
      }

      spec {
        container {
          name  = var.kube_deploy_container_name // The name of the container within the pod.
          image = var.kube_deploy_image // The image to be used for the container.
          image_pull_policy = var.kube_deploy_pull_policy // The image pull policy for the container.

          port {
            container_port = var.kube_deploy_port // The port to expose on the container.
          }
          
          resources {
            // The requested CPU and memory resources for the container.
            requests {
              cpu    = var.kube_deploy_request_cpu
              memory = var.kube_deploy_request_memory
            }
            
            // The limit on the CPU and memory resources for the container.
            limits {
              cpu    = var.kube_deploy_limits_cpu
              memory = var.kube_deploy_limits_memory
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
    name = var.kube_service_name // The name of the Kubernetes service.
  }
  spec {
    // The selector for the pods that this service should manage.
    selector = {
      app = var.kube_deploy_label
    }
    port {
      port        = var.kube_service_port // The port that this service should expose.
      target_port = var.kube_service_target_port // The port on the target pods that this service should send traffic to.
    }
    type = var.kube_service_type // The type of the service. "LoadBalancer" means that the service will be exposed to the internet.
  }

  // The dependencies for the Kubernetes service resource.
  depends_on = [kubernetes_deployment.transexpress-website]
}
