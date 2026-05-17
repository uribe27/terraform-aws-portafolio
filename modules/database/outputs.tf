output "db_instance_id" {
  description = "ID de la instancia RDS."
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "ARN de la instancia RDS. Usado por el módulo de monitoring."
  value       = aws_db_instance.main.arn
}

output "db_endpoint" {
  description = "Endpoint de conexión a la base de datos (host:puerto)."
  value       = aws_db_instance.main.endpoint
}

output "db_address" {
  description = "Hostname del endpoint RDS, sin puerto."
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "Puerto de conexión PostgreSQL."
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Nombre de la base de datos inicial."
  value       = aws_db_instance.main.db_name
}
