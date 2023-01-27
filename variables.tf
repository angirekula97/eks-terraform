variable "cluster-name" {
  default = "eks-cluster"
  type = string
  description = "name of the EKS cluster"
}

variable "aws-region" {
  default = "eu-central-1"
  type = string
  description = "AWS region to deploy EKS"
}

variable "k8s-version" {
  default = "1.21"
  type = string
  description = "K8S version"
}

variable "node-instance-type" {
  default     = "t3.medium"
  type        = string
  description = "Worker Node EC2 instance type"
}

variable "root-block-size" {
  default     = "20"
  type        = string
  description = "Size of the root EBS block device"

}

variable "desired-capacity" {
  default     = 2
  type        = string
  description = "Autoscaling Desired node capacity"
}

variable "max-size" {
  default     = 4
  type        = string
  description = "Autoscaling maximum node capacity"
}

variable "min-size" {
  default     = 2
  type        = string
  description = "Autoscaling Minimum node capacity"
}

variable vpc_name {
  description = "Name of the VPC"
  default = "eks-vpc"
}



variable vpc_cidr {
  default = "20.53.0.0/16"
}


variable public_subnet_cidr_blocks {
  default = {
    az0 = "20.53.100.0/24"
    az1 = "20.53.101.0/24"
  }
}

variable private_subnet_cidr_blocks {
  default = {
    az0 = "20.53.200.0/24"
    az1 = "20.53.201.0/24"
  }
}
