output "vpc_id" {
  value = aws_vpc.main.id
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
  description = "EC2 instance public IP"
}

output "ec2_public_dns" {
  value = aws_instance.web.public_dns
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_status" {
  value = aws_eks_cluster.main.status
}