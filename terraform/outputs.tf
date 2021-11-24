output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "public_route_table_association_ids" {
  value = aws_route_table_association.public.*.id
}
