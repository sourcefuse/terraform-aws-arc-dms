## VPC
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.namespace}-${var.environment}-vpc"]
  }
}

## Network
data "aws_subnets" "this" {
  filter {
    name = "tag:Name"
    values = [
      "${var.project_name}-${var.environment}-subnet-${var.region}a",
      "${var.project_name}-${var.environment}-subnet-${var.region}b"
    ]
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
  name = "source-secret"
}

data "aws_secretsmanager_secret" "target-secret" {
  name = "target-secret"
}
