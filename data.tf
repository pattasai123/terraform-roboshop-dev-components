data "aws_ami" "joindevops" {
  most_recent = true
  owners      = ["832510228841"]
}

data "aws_ssm_parameter" "private_subnet_a" {
  name = "/${var.project}/${var.env}/private_subnet_a"
}

data "aws_ssm_parameter" "private_subnet_b" {
  name = "/${var.project}/${var.env}/private_subnet_b"
}

data "aws_ssm_parameter" "sg_id" {
  name = "/${var.project}/${var.env}/${components}_sg_id"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project}/${var.env}/vpc_id"
}

data "aws_route53_zone" "zone" {
  name         = "bongu.online"
  private_zone = false
}

data "aws_ssm_parameter" "backend_listener_arn" {
  name = "/${var.project}/${var.env}/backend_listener_arn"
}

data "aws_ssm_parameter" "frontend_listener_arn" {
  name = "/${var.project}/${var.env}/frontend_listener_arn"
}