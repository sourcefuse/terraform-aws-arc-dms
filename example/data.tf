## VPC
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.namespace}-${var.environment}-vpc"]
  }
}

## Network - Public Subnets
data "aws_subnets" "this" {
  filter {
    name = "tag:Name"
    values = [
      "${var.project_name}-${var.environment}-public-subnet-public-${var.region}a",
      "${var.project_name}-${var.environment}-public-subnet-public-${var.region}b"
    ]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

## Security
data "aws_security_groups" "this" {
  filter {
    name   = "tag:Name"
    values = ["sg-dms"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

## Secrets Manager
data "aws_secretsmanager_secret" "source-secret" {
  name = "arc-poc-rds-connection-details"
}

data "aws_secretsmanager_secret" "target-secret" {
  name = "arc-dev-target-database-connection"
}
