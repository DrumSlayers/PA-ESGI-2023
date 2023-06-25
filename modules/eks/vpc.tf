// Crée un VPC
resource "aws_vpc" "eks-cluster" {
  cidr_block = var.vpc_cidr_eks

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                           = "${var.project_eks}-vpc",
    "kubernetes.io/cluster/${var.project_eks}-cluster" = "shared"
  }
}

// Crée sous-réseaux privés dans le VPC dans différentes zones de disponibilité
resource "aws_subnet" "private" {
  count = var.availability_zones_count

  vpc_id            = aws_vpc.eks-cluster.id
  cidr_block        = cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, count.index + var.availability_zones_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                           = "${var.project_eks}-private-sg"
    "kubernetes.io/cluster/${var.project_eks}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"              = 1
  }
}

// Crée sous-réseaux publics dans le VPC dans différentes zones de disponibilité
resource "aws_subnet" "public" {
  count = var.availability_zones_count

  vpc_id            = aws_vpc.eks-cluster.id
  cidr_block        = cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                           = "${var.project_eks}-public-sg"
    "kubernetes.io/cluster/${var.project_eks}-cluster" = "shared"
    "kubernetes.io/role/elb"                       = 1
  }

  map_public_ip_on_launch = true
}

// Création Internet gateway
resource "aws_internet_gateway" "eks-cluster" {
  vpc_id = aws_vpc.eks-cluster.id

  tags = {
    "Name" = "${var.project_eks}-igw"
  }

  depends_on = [aws_vpc.eks-cluster]
}

# Route Table(s)
# Route the public subnet traffic through the IGW
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.eks-cluster.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-cluster.id
  }

  tags = {
    Name = "${var.project_eks}-Default-rt"
  }
}

# Route table and subnet associations
resource "aws_route_table_association" "internet_access" {
  count = var.availability_zones_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.main.id
}

# NAT Elastic IP
resource "aws_eip" "main" {
  vpc = true

  tags = {
    Name = "${var.project_eks}-ngw-ip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_eks}-ngw"
  }
}

# Add route to route table
resource "aws_route" "main" {
  route_table_id         = aws_vpc.eks-cluster.default_route_table_id
  nat_gateway_id         = aws_nat_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

# Security group for public subnet
resource "aws_security_group" "public_sg" {
  name   =  "${var.project_eks}-Public-sg"
  vpc_id = aws_vpc.eks-cluster.id

  tags = {
    Name = "${var.project_eks}-Public-sg"
  }
}

# Security group traffic rules
resource "aws_security_group_rule" "sg_ingress_public_443" {
  security_group_id = aws_security_group.public_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_ingress_public_80" {
  security_group_id = aws_security_group.public_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_egress_public" {
  security_group_id = aws_security_group.public_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group for data plane
resource "aws_security_group" "data_plane_sg" {
  name   =  "${var.project_eks}-Worker-sg"
  vpc_id = aws_vpc.eks-cluster.id

  tags = {
    Name = "${var.project_eks}-Worker-sg"
  }
}

# Security group traffic rules
resource "aws_security_group_rule" "nodes" {
  description       = "Allow nodes to communicate with each other"
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = flatten([cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 0), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 1), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 2), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 3)])
}

resource "aws_security_group_rule" "nodes_inbound" {
  description       = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "ingress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = flatten([cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 2), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 3)])
}

resource "aws_security_group_rule" "node_outbound" {
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group for control plane
resource "aws_security_group" "control_plane_sg" {
  name   = "${var.project_eks}-ControlPlane-sg"
  vpc_id = aws_vpc.eks-cluster.id

  tags = {
    Name = "${var.project_eks}-ControlPlane-sg"
  }
}

# Security group traffic rules
resource "aws_security_group_rule" "control_plane_inbound" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = flatten([cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 0), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 1), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 2), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 3)])
}

resource "aws_security_group_rule" "control_plane_outbound" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project_eks}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks-cluster.id

  tags = {
    Name = "${var.project_eks}-cluster-sg"
  }
}

resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "egress"
}

// EKS Node security group
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_eks}-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.eks-cluster.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                           = "${var.project_eks}-node-sg"
    "kubernetes.io/cluster/${var.project_eks}-cluster" = "owned"
  }
}

resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_cluster_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}