#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#


resource "aws_iam_role" "node" {
  name = "${var.cluster-name}-eks-node-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}


## EKS Node group resource 
resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster-name}-default-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.eks-private[*].id
  #private_ip      = cidrhost(lookup(var.private_subnet_cidr_blocks,"az${count.index}"),20+count.index)
  scaling_config {
    desired_size = var.desired-capacity
    max_size     = var.max-size
    min_size     = var.min-size
  }
  instance_types = [
    var.node-instance-type
  ]
  
  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = {
    Name = "${var.cluster-name}-node-group"
  }
}


## EKS node security group
resource "aws_security_group" "node" {
  name        = "node-sg"
  description = "EKS node security groups"
  vpc_id      = aws_vpc.eks-vpc.id

  ingress {
    from_port        = 1025
    to_port          = 65535
    protocol         = "tcp"
    description      = "Allow EKS Control Plane"
    cidr_blocks      = [var.vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster-name}-eks-node-sg"
  }
}