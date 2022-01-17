locals {
  cfn_parameters_filepath = "../cfn/parameters.json"
}

resource "local_file" "cfn_parameters" {
  content  = templatefile("${path.module}/templates/parameters.tpl", {
    subnet_id      = aws_subnet.private.0.id
    route_table_id = aws_route_table.private.0.id
  })
  filename = pathexpand(local.cfn_parameters_filepath)
}
