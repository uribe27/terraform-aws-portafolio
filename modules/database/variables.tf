variable "project" {
  description = "Nombre del proyecto. Se usa como prefijo en todos los recursos."
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (dev, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "El entorno debe ser 'dev' o 'prod'."
  }
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos."
  type        = map(string)
  default     = {}
}

# --- Red ---

variable "private_subnet_ids" {
  description = "IDs de las subnets privadas donde se desplegará la RDS."
  type        = list(string)
}

# --- Seguridad ---

variable "sg_rds_id" {
  description = "ID del Security Group de RDS."
  type        = string
}

# --- Base de datos ---

variable "db_name" {
  description = "Nombre de la base de datos inicial."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Usuario administrador de la base de datos."
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Contraseña del usuario administrador. Debe gestionarse con un secret manager en producción."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Clase de instancia RDS."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Almacenamiento inicial en GB."
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Almacenamiento máximo en GB para autoscaling de storage. 0 deshabilita el autoscaling."
  type        = number
  default     = 0
}

variable "db_engine_version" {
  description = "Versión del motor PostgreSQL."
  type        = string
  default     = "16.3"
}

variable "db_backup_retention_days" {
  description = "Días de retención de backups automáticos. 0 deshabilita los backups."
  type        = number
  default     = 7
}