resource "aws_security_group" "alb" {
  name        = "${local.resource_prefix}-alb"
  description = "The security group used to grant access to the ALB"

  vpc_id = aws_vpc.vpc.id


  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "api_ingress" {
  name        = "${local.resource_prefix}-ecs-ingress"
  description = "Access ECS containers from ALB"

  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [
      aws_security_group.alb.id]
  }

  tags = local.common_tags
}
