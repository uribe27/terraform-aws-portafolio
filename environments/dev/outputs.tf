# ==============================================================================
# Outputs del entorno dev
# Exponen los valores clave de la infraestructura desplegada.
# ==============================================================================

# --- Networking ---

output "vpc_id" {
  description = "ID de la VPC del entorno dev."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs de las subnets públicas."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs de las subnets privadas."
  value       = module.networking.private_subnet_ids
}

# --- Compute ---

output "alb_dns_name" {
  description = "DNS público del Application Load Balancer. Punto de entrada a la aplicación."
  value       = module.compute.alb_dns_name
}

output "asg_name" {
  description = "Nombre del Auto Scaling Group."
  value       = module.compute.asg_name
}

# --- Database ---

output "db_endpoint" {
  description = "Endpoint de conexión a la RDS (host:puerto)."
  value       = module.database.db_endpoint
}

output "db_port" {
  description = "Puerto de conexión PostgreSQL."
  value       = module.database.db_port
}

output "db_name" {
  description = "Nombre de la base de datos inicial."
  value       = module.database.db_name
}
