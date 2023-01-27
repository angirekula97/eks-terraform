#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "cluster" {
  name = "${var.cluster-name}-eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

resource "aws_security_group" "cluster" {
  name        = "cluster-sg"
  description = "EKS cluster security groups"
  vpc_id      = aws_vpc.eks-vpc.id
  
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    #cidr_blocks      = [data.aws_vpc.eks-vpc.cidr_block]
    cidr_blocks      = [var.vpc_cidr]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  
  tags = {
    Name = "${var.cluster-name}-eks-cluster-sg"
  }
}


resource "aws_eks_cluster" "eks" {
  name = var.cluster-name
  role_arn = aws_iam_role.cluster.arn
  version = var.k8s-version
  #private_ip      = cidrhost(lookup(var.private_subnet_cidr_blocks,"az${count.index}"),20+count.index)

  vpc_config {
    security_group_ids = [aws_security_group.cluster.id]
    subnet_ids = aws_subnet.eks-public[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
  ]
  tags = {
    Name = "${var.cluster-name}-master"
  }
}