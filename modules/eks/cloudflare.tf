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