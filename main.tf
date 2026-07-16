resource "aws_instance" "main" {
  ami                    = local.ami
  instance_type          = var.instance_type

  subnet_id              = local.subnet[0]
  vpc_security_group_ids = [local.sg_id]

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.common_name}-${local.component}"
    }
  )
}
resource "terraform_data" "main" {
 
  triggers_replace = [
    aws_instance.main.id
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    = "DevOps321"
    host        = aws_instance.main.private_ip
  }
  provisioner "file" {
    source      = "bootstrap.sh"             # Path on your local machine
    destination = "/tmp/bootstrap.sh"     # Path on the remote server
  }
  provisioner "remote-exec" {
    
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh ${local.component} ${var.env}"
    ]
  }
}
/*
resource "aws_route53_record" "route53" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${local.component}-${var.env}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.main.private_ip]
  allow_overwrite = true
}
*/
resource "aws_ec2_instance_state" "main" {
  instance_id = aws_instance.main.id
  state       = "stopped" # Valid values: running, stopped
  depends_on = [terraform_data.main]
}

resource "aws_ami_from_instance" "main" {
  name               = "terraform-${local.component}"
  source_instance_id = aws_instance.main.id
  depends_on = [aws_ec2_instance_state.main]
}

resource "aws_lb_target_group" "main" {
  name     = "${local.common_name}-${local.component}-lb-tg"
  port     = local.port
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  deregistration_delay = 100
  health_check{
    enabled= "true"
    healthy_threshold = 2
    interval = 10
    matcher = "200-299"
    path = local.path
    port = 8080
    protocol = "HTTP"
    unhealthy_threshold = 2
  }
  depends_on = [aws_ami_from_instance.main]
}

resource "aws_launch_template" "main" {
  name      = "${local.common_name}-${local.component}-launch-template"
  image_id  = aws_ami_from_instance.main.id
  instance_type = "t3.micro"

  instance_initiated_shutdown_behavior = "terminate"

  vpc_security_group_ids = [local.sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = "${local.common_name}-${local.component}"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name = "${local.common_name}-${local.component}"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-${local.component}"
    }
  )

  depends_on = [aws_lb_target_group.main]
}

resource "aws_autoscaling_group" "main" {
  vpc_zone_identifier = local.subnet
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  depends_on = [aws_launch_template.main]
}

resource "aws_autoscaling_policy" "main" {
  name                   = "${local.common_name}-${local.component}-autoscaling-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 100
  autoscaling_group_name = aws_autoscaling_group.main.name
  depends_on = [aws_autoscaling_group.main]
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = local.listener
  priority     = local.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = [local.host_header]
    }
  }
  depends_on = [aws_autoscaling_policy.main]
}

resource "terraform_data" "main-delete" {
  triggers_replace = [
    aws_instance.main.id
  ]
  depends_on = [aws_lb_listener_rule.main]
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.main.id}"
  }
}