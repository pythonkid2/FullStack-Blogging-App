output "cluster_id" {
  value = aws_eks_cluster.mega_project.id
}

output "node_group_id" {
  value = aws_eks_node_group.mega_project.id
}

output "vpc_id" {
  value = aws_vpc.mega_project_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.mega_project_subnet[*].id
}
