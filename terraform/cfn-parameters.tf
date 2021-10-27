locals {
  cfn_parameters_filepath = "../cfn/parameters.json"
}

data "template_file" "cfn_parameters" {
  template = file("${path.module}/templates/parameters.tpl")

  vars = {
    subnet_id      = aws_subnet.private.0.id
    route_table_id = aws_route_table.private.0.id
  }
}

resource "local_file" "cfn_parameters" {
  content  = data.template_file.cfn_parameters.rendered
  filename = pathexpand(local.cfn_parameters_filepath)
}