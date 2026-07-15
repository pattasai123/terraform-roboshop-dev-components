locals {
  ami              = data.aws_ami.joindevops.id
  sg_id    = data.aws_ssm_parameter.sg_id.value
   subnet=[
    data.aws_ssm_parameter.private_subnet_a.value,
    data.aws_ssm_parameter.private_subnet_b.value
    ]
    frontend_listener_arn    = data.aws_ssm_parameter.frontend_listener_arn.value
    backend_listener_arn    = data.aws_ssm_parameter.backend_listener_arn.value
    listener = "${var.components}" == "frontend" ? local.frontend_listener_arn : local.backend_listener_arn
    host_header = "${var.components}" == "frontend" ? "${var.project}.${var.env}.${var.domain_name}" :"${var.components}.backend-alb-${var.env}.${var.domain_name}" 
    port = "${var.components}" == "frontend" ? 80 : 8080
    path= "${var.components}" == "frontend" ? "/" : "/health"
    component="${var.components}"
  common_name = "${var.project}-${var.env}"
  common_tags = {
    project   = var.project
    env       = var.env
    terraform = true
  }
}