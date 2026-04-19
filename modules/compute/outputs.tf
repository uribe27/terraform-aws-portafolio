output "alb_dns_name" {
  description = "DNS público del Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN del Application Load Balancer. Usado por el módulo de monitoring."
  value       = aws_lb.main.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix del ALB. Necesario para las métricas de CloudWatch."
  value       = aws_lb.main.arn_suffix
}

output "target_group_arn_suffix" {
  description = "ARN suffix del Target Group. Necesario para las métricas de CloudWatch."
  value       = aws_lb_target_group.app.arn_suffix
}

output "asg_name" {
  description = "Nombre del Auto Scaling Group. Usado por el módulo de monitoring."
  value       = aws_autoscaling_group.app.name
}
