data "aws_availability_zones" "available" {}

locals {
  availability_zones = data.aws_availability_zones.available.names
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = merge(local.common_tags, {
    Name = local.resource_prefix,
  })
}

resource "aws_subnet" "public" {
  count = var.number_of_azs

  availability_zone = local.availability_zones[count.index]
  cidr_block        = "10.0.${count.index + 10}.0/24"
  vpc_id            = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-public-${local.availability_zones[count.index]}"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-igw"
  })
}

// Non-NAT Routing
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-route-table-public"
  })

}

resource "aws_route_table_association" "public" {
  count = var.number_of_azs

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count = var.number_of_azs

  availability_zone = local.availability_zones[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    "Name" = "${local.resource_prefix}-private-${local.availability_zones[count.index]}"
  })
}

// Nat Gateways
resource "aws_eip" "nat_gateway_eip" {
  count = var.number_of_azs

  vpc = true

  tags = merge(local.common_tags, {
    Name  = "nat_gateway_eip_az_${local.availability_zones[count.index]}"
    stage = var.stage
  })
}

resource "aws_nat_gateway" "natgw" {
  count = var.number_of_azs

  allocation_id = aws_eip.nat_gateway_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [
    aws_internet_gateway.igw]

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-natgw-${local.availability_zones[count.index]}"
  })
}

resource "aws_route_table" "private" {
  count = var.number_of_azs

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw[count.index].id
  }

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-private-${local.availability_zones[count.index]}"
  })
}

resource "aws_route_table_association" "private" {
  count = var.number_of_azs

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

// Security Groups
resource "aws_security_group" "egress_all" {
  name        = "${local.resource_prefix}-egress-all"
  description = "Access to interwebs"

  vpc_id = aws_vpc.vpc.id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = local.common_tags
}

// main route table
resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route = []

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-route-table-main"
  })
}
