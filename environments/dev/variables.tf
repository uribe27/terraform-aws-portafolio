# ==============================================================================
# Variables del entorno dev
# ==============================================================================

# --- Base de datos ---

variable "db_password" {
  description = "Contraseña del usuario administrador de la RDS. Pasar via variable de entorno TF_VAR_db_password o fichero .tfvars (nunca en el código fuente)."
  type        = string
  sensitive   = true
}
