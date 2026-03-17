#!/bin/bash

set -euo pipefail

ENVIRONMENT="${1:?Error: debes indicar el entorno (dev|prod)}"
PROJECT="portfolio"
REGION="eu-west-1"
BUCKET_NAME="${PROJECT}-terraform-state-${ENVIRONMENT}"
DYNAMODB_TABLE="${PROJECT}-terraform-locks-${ENVIRONMENT}"

echo "=== Bootstrap del estado remoto ==="
echo "Entorno   : ${ENVIRONMENT}"
echo "Bucket S3 : ${BUCKET_NAME}"
echo "DynamoDB  : ${DYNAMODB_TABLE}"
echo ""

# Crear bucket S3
echo "[1/3] Creando bucket S3..."
aws s3api create-bucket \
  --bucket "${BUCKET_NAME}" \
  --region "${REGION}" \
  --create-bucket-configuration LocationConstraint="${REGION}"

# Habilitar versionado
echo "[2/3] Habilitando versionado y cifrado..."
aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Crear tabla DynamoDB
echo "[3/3] Creando tabla DynamoDB..."
aws dynamodb create-table \
  --table-name "${DYNAMODB_TABLE}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "${REGION}"

echo ""
echo "=== Bootstrap completado ==="
