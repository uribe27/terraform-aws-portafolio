# ==============================================================================
# DB Subnet Group — Agrupa las subnets privadas donde puede vivir la RDS.
# RDS requiere subnets en al menos 2 AZs distintas para poder activar Multi-AZ.
# ==============================================================================

resource "aws_db_subnet_group" "main" {
  name        = "${var.project}-${var.environment}-db-subnet-group"
  description = "Subnet group para RDS PostgreSQL en subnets privadas."
  subnet_ids  = var.private_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.environment}-db-subnet-group"
  })
}

# ==============================================================================
# RDS PostgreSQL — Base de datos relacional principal.
# En prod: Multi-AZ activado, storage autoscaling habilitado, deletion protection.
# En dev:  Single-AZ, sin autoscaling, sin protección ante borrado.
# ==============================================================================

resource "aws_db_instance" "main" {
  identifier = "${var.project}-${var.environment}-rds"

  # Motor
  engine         = "postgres"
  engine_version = var.db_engine_version

  # Instancia y almacenamiento
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"

  # Cifrado en reposo: siempre activo independientemente del entorno
  storage_encrypted = true

  # Credenciales
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Red y seguridad
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.sg_rds_id]

  # La instancia nunca es accesible directamente desde Internet
  publicly_accessible = false

  # Alta disponibilidad: Multi-AZ solo en prod
  # En dev es innecesario y costoso
  multi_az = var.environment == "prod" ? true : false

  # Backups: retención configurable por entorno
  backup_retention_period = var.db_backup_retention_days

  # Ventana de mantenimiento en horario de bajo tráfico (madrugada UTC)
  maintenance_window      = "mon:03:00-mon:04:00"
  backup_window           = "02:00-03:00"

  # Actualizaciones automáticas de parches menores: activo en ambos entornos
  auto_minor_version_upgrade = true

  # Monitorización enhanced: 60 segundos en dev, 30 en prod
  monitoring_interval = var.environment == "prod" ? 30 : 60

  # Protección ante borrado accidental: solo en prod
  deletion_protection = var.environment == "prod" ? true : false

  # En dev se permite destruir la RDS sin snapshot final para agilizar pruebas
  skip_final_snapshot       = var.environment == "prod" ? false : true
  final_snapshot_identifier = var.environment == "prod" ? "${var.project}-${var.environment}-rds-final-snapshot" : null

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.environment}-rds"
  })
}
