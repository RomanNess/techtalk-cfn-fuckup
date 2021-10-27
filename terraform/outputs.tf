output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public.0.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "public_route_table_association_id" {
  value = aws_main_route_table_association.public.id
}
