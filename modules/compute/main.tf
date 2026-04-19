# ==============================================================================
# ALB — Application Load Balancer
# Recibe el tráfico público (80/443) y lo distribuye a las instancias privadas.
# ==============================================================================

resource "aws_lb" "main" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.public_subnet_ids

  # Protección ante borrado accidental en producción
  enable_deletion_protection = var.environment == "prod" ? true : false

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.environment}-alb"
  })
}

# Target Group: define cómo el ALB comprueba la salud de las instancias
resource "aws_lb_target_group" "app" {
  name        = "${var.project}-${var.environment}-tg-app"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.environment}-tg-app"
  })
}

# Listener HTTP en el puerto 80 — reenvía todo el tráfico al Target Group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ==============================================================================
# Launch Template — Plantilla de configuración de las instancias EC2
# El ASG usará esta plantilla para lanzar nuevas instancias de forma consistente.
# ==============================================================================

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project}-${var.environment}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  # Instance Profile: permite a la instancia asumir el IAM Role (SSM, etc.)
  iam_instance_profile {
    name = var.ec2_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false # Las EC2 viven en subnets privadas
    security_groups             = [var.sg_ec2_id]
  }

  # Metadatos IMDSv2: obliga a usar tokens para consultar los metadatos de la instancia.
  # Previene ataques SSRF que intenten robar credenciales del metadata service.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # User data mínimo: instala el agente SSM en Amazon Linux 2023 / Ubuntu.
  # Permite conectarse a las instancias sin abrir SSH ni bastión.
  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    # Agente SSM (ya incluido en Amazon Linux 2023; línea de seguridad para otras AMIs)
    if command -v snap &>/dev/null; then
      snap install amazon-ssm-agent --classic
    fi
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  USERDATA
  )

  # Cada nueva versión del LT sustituye a la anterior; el ASG apunta siempre a $Latest
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.environment}-lt"
  })
}

# ==============================================================================
# Auto Scaling Group — Gestiona la flota de instancias EC2
# Distribuye las instancias entre las subnets privadas de las distintas AZs.
# ==============================================================================

resource "aws_autoscaling_group" "app" {
  name = "${var.project}-${var.environment}-asg"

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  vpc_zone_identifier = var.private_subnet_ids

  # Registra automáticamente las instancias nuevas en el Target Group del ALB
  target_group_arns = [aws_lb_target_group.app.arn]

  # ELB: el ASG espera a que el ALB marque la instancia como healthy antes
  # de considerarla lista. Evita enviar tráfico a instancias que aún arrancan.
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Política de refresco: sustituye instancias de forma gradual al actualizar el LT.
  # min_healthy_percentage garantiza que siempre hay capacidad disponible durante el update.
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  # Propaga los common_tags a las instancias EC2 que lance el ASG
  dynamic "tag" {
    for_each = merge(var.common_tags, {
      Name = "${var.project}-${var.environment}-ec2"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# Auto Scaling Policy — Escalado automático por CPU
# Mantiene el uso medio de CPU alrededor del 60 %. Si sube, añade instancias;
# si baja, las retira. Target Tracking es la política más sencilla y efectiva.
# ==============================================================================

resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${var.project}-${var.environment}-asg-policy-cpu"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}
