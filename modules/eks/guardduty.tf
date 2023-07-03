data "aws_vpc_endpoint_service" "guardduty" {
  service_type = "Interface"
  filter {
    name   = "service-name"
    values = ["com.amazonaws.${var.aws_region}.guardduty-data"]
  }
}

resource "aws_vpc_endpoint" "eks_vpc_guardduty" {
  vpc_id            = aws_vpc.eks-cluster.id
  service_name      = data.aws_vpc_endpoint_service.guardduty.service_name
  vpc_endpoint_type = "Interface"
  
  policy = data.aws_iam_policy_document.eks_vpc_guardduty.json

  security_group_ids  = [aws_security_group.eks_vpc_endpoint_guardduty.id]
  subnet_ids          = [for s in aws_subnet.public : s.id]
  private_dns_enabled = true
}

resource "aws_security_group" "eks_vpc_endpoint_guardduty" {
  name_prefix = "${var.project_eks}-vpc-endpoint-guardduty-sg-"
  description = "Security Group used by VPC Endpoints."
  vpc_id      = aws_vpc.eks-cluster.id

  tags = {
    "Name"             = "${var.project_eks}-vpc-endpoint-guardduty-sg-"
    "GuardDutyManaged" = "false"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_vpc_guardduty_ingress" {
  security_group_id = aws_security_group.eks_vpc_endpoint_guardduty.id
  description       = "Ingress for port 443."

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}


data "aws_iam_policy_document" "eks_vpc_guardduty" {
  statement {
    actions = ["*"]

    effect = "Allow"

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    actions = ["*"]

    effect = "Deny"

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalAccount"

      values = [var.aws_account_id]
    }
  }
}


resource "aws_eks_addon" "guardduty" {

  cluster_name      = aws_eks_cluster.eks-cluster.name
  addon_name        = "aws-guardduty-agent"
  addon_version     = "v1.2.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"

  preserve = true

  tags = {
    "eks_addon" = "guardduty"
  }
  depends_on = [
    aws_eks_node_group.eks-cluster,
    helm_release.cluster_autoscaler
  ]
}