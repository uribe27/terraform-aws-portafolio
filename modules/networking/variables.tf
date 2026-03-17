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

variable "vpc_cidr" {
  description = "Bloque CIDR principal de la VPC."
  type        = string
  default     = "10.0.0.0/26"
}

variable "public_subnet_cidrs" {
  description = "Lista de CIDRs para las subnets públicas."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Lista de CIDRs para las subnets privadas."
  type        = list(string)
}

variable "availability_zones" {
  description = "Lista de Availability Zones."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Si es true, se crea un NAT Gateway."
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos."
  type        = map(string)
  default     = {}
}