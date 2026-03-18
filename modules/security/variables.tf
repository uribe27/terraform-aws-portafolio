variable "project" {
  description = "Nombre del proyecto."
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

variable "vpc_id" {
  description = "ID de la VPC donde se crearán los Security Groups."
  type        = string
}

variable "app_port" {
  description = "Puerto en el que escucha la aplicación en EC2."
  type        = number
  default     = 8080
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos."
  type        = map(string)
  default     = {}
}