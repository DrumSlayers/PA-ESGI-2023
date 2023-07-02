// Creates a Virtual Private Cloud (VPC) which acts as a private section of the AWS cloud 
// with its own network and infrastructure.
resource "aws_vpc" "eks-cluster" {
  cidr_block = var.vpc_cidr_eks // The IP address range for the VPC.

  // Enable DNS hostname and support for the instances in the VPC
  enable_dns_hostnames = true 
  enable_dns_support   = true 

  tags = {
    Name = "${var.project_eks}-vpc",
    "kubernetes.io/cluster/${var.project_eks}-cluster" = "shared" // Tags the VPC for Kubernetes.
  }
}

// Creates private subnets within the VPC across multiple Availability Zones (AZs).
// These are isolated network spaces that will host the EKS worker nodes.
resource "aws_subnet" "private" {
  count = var.availability_zones_count // One subnet per AZ.

  vpc_id            = aws_vpc.eks-cluster.id // The ID of the VPC where this subnet is to be created.
  cidr_block        = cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, count.index + var.availability_zones_count) // The IP address range for the subnet.
  availability_zone = data.aws_availability_zones.available.names[count.index] // The AZ where the subnet will be created.

  tags = {
    Name = "${var.project_eks}-private-sg"
    "kubernetes.io/cluster/${var.project_eks}-cluster" = "shared" // Tags the subnet for Kubernetes.
    "kubernetes.io/role/internal-elb" = 1 // Tags the subnet for use with internal load balancers.
  }
}

// Creates public subnets within the VPC across multiple AZs. 
// These subnets can house resources that need to be accessible from the Internet.
resource "aws_subnet" "public" {
  count = var.availability_zones_count // One subnet per AZ.

  vpc_id            = aws_vpc.eks-cluster.id
  cidr_block        = cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, count.index) // The IP address range for the subnet.
  availability_zone = data.aws_availability_zones.available.names[count.index] // The AZ where the subnet will be created.

  tags = {
    Name = "${var.project_eks}-public-sg"
    "kubernetes.io/cluster/${var.project_eks}-cluster" = "shared" // Tags the subnet for Kubernetes.
    "kubernetes.io/role/elb" = 1 // Tags the subnet for use with external load balancers.
  }

  map_public_ip_on_launch = true // Automatically assign public IP to instances launched in this subnet.
}

// The Internet Gateway allows the resources in the VPC to access the Internet.
resource "aws_internet_gateway" "eks-cluster" {
  vpc_id = aws_vpc.eks-cluster.id // Attach to the VPC.

  tags = {
    "Name" = "${var.project_eks}-igw"
  }

  depends_on = [aws_vpc.eks-cluster] // This depends on the VPC being created first.
}

// Route Table that routes traffic from the VPC to the Internet through the Internet Gateway.
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.eks-cluster.id // The ID of the VPC where this route table is to be created.

  route {
    cidr_block = "0.0.0.0/0" // All IP addresses.
    gateway_id = aws_internet_gateway.eks-cluster.id // Route via the Internet Gateway.
  }

  tags = {
    Name = "${var.project_eks}-Default-rt"
  }
}

// Association of the route table to the public subnets to enable Internet access.
resource "aws_route_table_association" "internet_access" {
  count = var.availability_zones_count // One association per subnet.

  subnet_id      = aws_subnet.public[count.index].id // The subnet to associate with the route table.
  route_table_id = aws_route_table.main.id // The route table to associate.
}

// Elastic IP for the NAT Gateway. 
// This IP address will be the public-facing IP for Internet-bound traffic from the private subnets.
resource "aws_eip" "main" {
  vpc = true // Allocate the Elastic IP in the VPC.

  tags = {
    Name = "${var.project_eks}-ngw-ip"
  }
}

// NAT Gateway allows instances in the private subnets to reach out to the Internet.
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id // Use the previously created Elastic IP.
  subnet_id     = aws_subnet.public[0].id // Place the NAT Gateway in a public subnet.

  tags = {
    Name = "${var.project_eks}-ngw"
  }
}

// Adds a route to the main route table to enable the NAT Gateway.
// This allows resources in private subnets to reach the Internet.
resource "aws_route" "main" {
  route_table_id         = aws_vpc.eks-cluster.default_route_table_id
  nat_gateway_id         = aws_nat_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"  // All IP addresses.
}

// Creates a security group for the public subnet.
// Security groups act like a firewall for associated Amazon EC2 instances, controlling both inbound and outbound traffic.
resource "aws_security_group" "public_sg" {
  name   =  "${var.project_eks}-Public-sg"
  vpc_id = aws_vpc.eks-cluster.id // The VPC in which to create the security group.

  tags = {
    Name = "${var.project_eks}-Public-sg"
  }
}

// Defines the inbound rules for the public security group.
// This configuration allows incoming traffic on ports 80 and 443, which are used for HTTP and HTTPS respectively.
resource "aws_security_group_rule" "sg_ingress_public_443" {
  security_group_id = aws_security_group.public_sg.id
  type              = "ingress" // Inbound rule.
  from_port         = 443 // HTTPS
  to_port           = 443 // HTTPS
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] // All IP addresses.
}

resource "aws_security_group_rule" "sg_ingress_public_80" {
  security_group_id = aws_security_group.public_sg.id
  type              = "ingress" // Inbound rule.
  from_port         = 80 // HTTP
  to_port           = 80 // HTTP
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] // All IP addresses.
}

// Defines the outbound rules for the public security group.
// This configuration allows all outgoing traffic.
resource "aws_security_group_rule" "sg_egress_public" {
  security_group_id = aws_security_group.public_sg.id
  type              = "egress" // Outbound rule.
  from_port         = 0 // All ports.
  to_port           = 0 // All ports.
  protocol          = "-1" // All protocols.
  cidr_blocks       = ["0.0.0.0/0"] // All IP addresses.
}

// Creates a security group for the data plane.
// The data plane consists of the worker nodes that run the containers and compute tasks.
resource "aws_security_group" "data_plane_sg" {
  name   =  "${var.project_eks}-Worker-sg"
  vpc_id = aws_vpc.eks-cluster.id // The VPC in which to create the security group.

  tags = {
    Name = "${var.project_eks}-Worker-sg"
  }
}

// Defines the inbound rules for the data plane security group.
// This configuration allows all incoming traffic within the VPC.
resource "aws_security_group_rule" "nodes" {
  description       = "Allow nodes to communicate with each other"
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "ingress" // Inbound rule.
  from_port         = 0 // All ports.
  to_port           = 65535 // All ports.
  protocol          = "-1" // All protocols.
  cidr_blocks       = flatten([cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 0), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 1), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 2), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 3)]) // Subnets within the VPC.
}

// Additional inbound rules specific to the data plane.
// This configuration allows incoming communication from the control plane on ports 1025-65535.
resource "aws_security_group_rule" "nodes_inbound" {
  description       = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "ingress" // Inbound rule.
  from_port         = 1025 // Port 1025.
  to_port           = 65535 // Up to port 65535.
  protocol          = "tcp"
  cidr_blocks       = flatten([cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 2), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 3)]) // Subnets within the VPC.
}

// Defines the outbound rules for the data plane security group.
// This configuration allows all outgoing traffic.
resource "aws_security_group_rule" "node_outbound" {
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "egress" // Outbound rule.
  from_port         = 0 // All ports.
  to_port           = 0 // All ports.
  protocol          = "-1" // All protocols.
  cidr_blocks       = ["0.0.0.0/0"] // All IP addresses.
}

// Creates a security group for the control plane.
// The control plane manages the worker nodes and the Kubernetes API server.
resource "aws_security_group" "control_plane_sg" {
  name   = "${var.project_eks}-ControlPlane-sg"
  vpc_id = aws_vpc.eks-cluster.id // The VPC in which to create the security group.

  tags = {
    Name = "${var.project_eks}-ControlPlane-sg"
  }
}

// Defines the inbound and outbound rules for the control plane security group.
// The configuration allows all incoming and outgoing traffic within the VPC.
resource "aws_security_group_rule" "control_plane_inbound" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "ingress" // Inbound rule.
  from_port         = 0 // All ports.
  to_port           = 65535 // All ports.
  protocol          = "tcp"
  cidr_blocks       = flatten([cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 0), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 1), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 2), cidrsubnet(var.vpc_cidr_eks, var.subnet_cidr_bits_eks, 3)]) // Subnets within the VPC.
}

resource "aws_security_group_rule" "control_plane_outbound" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "egress" // Outbound rule.
  from_port         = 0 // All ports.
  to_port           = 65535 // All ports.
  protocol          = "-1" // All protocols.
  cidr_blocks       = ["0.0.0.0/0"] // All IP addresses.
}

// Creates a security group for the EKS cluster.
// This security group is used to control communication between the cluster and the worker nodes.
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project_eks}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks-cluster.id // The VPC in which to create the security group.

  tags = {
    Name = "${var.project_eks}-cluster-sg"
  }
}

// Defines the inbound and outbound rules for the EKS cluster security group.
// The configuration allows the worker nodes to communicate with the cluster's API server and vice versa.
resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress" // Inbound rule.
}

resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "egress" // Outbound rule.
}

// Creates a security group for all nodes in the EKS cluster.
// This security group is used to control communication within the nodes of the cluster.
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_eks}-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.eks-cluster.id // The VPC in which to create the security group.

  egress {
    from_port   = 0 // All ports.
    to_port     = 0 // All ports.
    protocol    = "-1" // All protocols.
    cidr_blocks = ["0.0.0.0/0"] // All IP addresses.
  }

  tags = {
    Name                                           = "${var.project_eks}-node-sg"
    "kubernetes.io/cluster/${var.project_eks}-cluster" = "owned"
  }
}

// Defines the inbound rules for the node security group.
// This configuration allows nodes to communicate with each other and the worker nodes to communicate with the cluster's API server.
resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0 // All ports.
  protocol                 = "-1" // All protocols.
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535 // All ports.
  type                     = "ingress" // Inbound rule.
}

resource "aws_security_group_rule" "nodes_cluster_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025 // Port 1025.
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535 // Up to port 65535.
  type                     = "ingress" // Inbound rule.
}