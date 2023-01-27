data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_vpc" "eks-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# Subnets (public)
resource "aws_subnet" "eks-public" {
  count                   = 2
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = lookup(var.public_subnet_cidr_blocks,"az${count.index}")
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-subnet-${count.index}"
    Type = "Public subnet"
  }
}

# Subnets (private)
resource "aws_subnet" "eks-private" {
  count                   = 2
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = lookup(var.private_subnet_cidr_blocks,"az${count.index}")
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "eks-private-subnet-${count.index}"
    Type = "Private subnet"
  }
}


resource "aws_internet_gateway" "eks-igw" {
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = "terraform-eks-igw"
  }
}

resource "aws_nat_gateway" "eks-igw" {
  depends_on = [aws_internet_gateway.eks-igw, aws_route_table_association.eks_public_route_assoc_az0]
  subnet_id  = aws_subnet.eks-public.*.id[0]
  allocation_id = aws_eip.nat_eip.id
}
resource "aws_eip" "nat_eip" {
  vpc = true
}


# Public subnet
resource "aws_route_table" "eks_public" {
    vpc_id = aws_vpc.eks-vpc.id

    # Default route through Internet Gateway
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.eks-igw.id
    }

}

#Private subnet
resource "aws_route_table" "eks_private" {
    vpc_id = aws_vpc.eks-vpc.id

    # Default route through Internet Gateway
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.eks-igw.id
    }
}



resource "aws_route_table_association" "eks_public_route_assoc_az0" {
  subnet_id = aws_subnet.eks-public.0.id
  route_table_id = aws_route_table.eks_public.id
}

resource "aws_route_table_association" "eks_public_route_assoc_az1" {
  subnet_id = aws_subnet.eks-public.1.id
  route_table_id = aws_route_table.eks_public.id
}

resource "aws_route_table_association" "eks_private_route_assoc_az0" {
  subnet_id = aws_subnet.eks-private.0.id
  route_table_id = aws_route_table.eks_private.id
}

resource "aws_route_table_association" "eks_private_route_assoc_az1" {
  subnet_id = aws_subnet.eks-private.1.id
  route_table_id = aws_route_table.eks_private.id
}

