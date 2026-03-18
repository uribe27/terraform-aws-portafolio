output "sg_alb_id" {
  description = "ID del Security Group del ALB."
  value       = aws_security_group.alb.id
}

output "sg_ec2_id" {
  description = "ID del Security Group de EC2."
  value       = aws_security_group.ec2.id
}

output "sg_rds_id" {
  description = "ID del Security Group de RDS."
  value       = aws_security_group.rds.id
}

output "ec2_instance_profile_name" {
  description = "Nombre del Instance Profile para EC2."
  value       = aws_iam_instance_profile.ec2.name
}

output "ec2_role_arn" {
  description = "ARN del IAM Role de EC2."
  value       = aws_iam_role.ec2.arn
}