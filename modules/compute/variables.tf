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

variable "vpc_id" {
  description = "ID de la VPC donde se desplegará el cómputo."
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs de las subnets públicas para el ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs de las subnets privadas para las instancias EC2."
  type        = list(string)
}

# --- Seguridad ---

variable "sg_alb_id" {
  description = "ID del Security Group del ALB."
  type        = string
}

variable "sg_ec2_id" {
  description = "ID del Security Group de las instancias EC2."
  type        = string
}

variable "ec2_instance_profile_name" {
  description = "Nombre del Instance Profile IAM para las instancias EC2."
  type        = string
}

# --- Instancia ---

variable "ami_id" {
  description = "ID de la AMI a usar en las instancias EC2. Parametrizable por entorno."
  type        = string
  # Sin default intencionado: obliga a declararlo explícitamente en cada entorno.
}

variable "instance_type" {
  description = "Tipo de instancia EC2."
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Puerto en el que escucha la aplicación. Debe coincidir con el Security Group de EC2."
  type        = number
  default     = 8080
}

# --- Auto Scaling ---

variable "asg_min_size" {
  description = "Número mínimo de instancias en el Auto Scaling Group."
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Número máximo de instancias en el Auto Scaling Group."
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Número deseado de instancias en el Auto Scaling Group."
  type        = number
  default     = 1
}
