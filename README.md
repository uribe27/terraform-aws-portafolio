# terraform-aws-portfolio

Infraestructura AWS modular y resiliente definida con Terraform.

Proyecto portfolio que demuestra buenas prácticas de IaC: separación por entornos,
módulos reutilizables, gestión de estado remoto y seguridad.

## Arquitectura
```
terraform-aws-portfolio/
├── environments/
│   ├── dev/          # Entorno de desarrollo
│   └── prod/         # Entorno de producción
├── modules/
│   ├── networking/   # VPC, subnets, IGW, NAT Gateway
│   ├── compute/      # EC2, Auto Scaling Group
│   ├── database/     # RDS PostgreSQL
│   └── security/     # IAM roles, Security Groups
└── scripts/          # Bootstrap del estado remoto
```
> **Nota:** Los rangos de red están dimensionados intencionalmente pequeños
> (VPC /26, subnets /28) ya que es un entorno de pruebas y portfolio.
> En un entorno productivo real se dimensionarían según los requisitos del proyecto.

## Requisitos

- Terraform >= 1.6.0
- AWS CLI configurado
- Cuenta AWS con permisos suficientes

## Uso

### 1. Bootstrap del estado remoto (solo la primera vez)
```bash
cd scripts/
./bootstrap-state.sh dev
```

### 2. Desplegar un entorno
```bash
cd environments/dev/
terraform init
terraform plan
terraform apply
```

## Módulos

| Módulo | Descripción |
|--------|-------------|
| networking | VPC, subnets públicas/privadas, NAT Gateway |
| compute | Auto Scaling Group con Launch Template |
| database | RDS PostgreSQL Multi-AZ en prod |
| security | Security Groups e IAM roles |

## Convenciones

- Región principal: eu-west-1 (Irlanda)
- Nomenclatura de recursos: `{proyecto}-{entorno}-{recurso}`
- Mensajes de commit: Conventional Commits
