################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = var.project_name

  extra_tags = {
    Example  = "True"
    RepoPath = "github.com/terraform-aws-modules"
  }
}

# AWS DMS

module "aws_dms" {
  source = "../modules/dms"

  # Subnet
  subnet_group_id          = "dms-poc-public-subnet-group"
  subnet_group_description = "Subnet for DMS POC"
  subnet_group_subnet_ids  = ["subnet-1", "subnet-2"] #List of Subnet IDs

  # Instance
  instance_allocated_storage      = 5
  instance_apply_immediately      = true
  instance_network_type           = "IPV4"
  instance_class                  = "dms.t2.micro"
  instance_id                     = "DMS-POC"
  instance_subnet_group_id        = "dms-poc-public-subnet-group"
  instance_publicly_accessible    = true
  instance_vpc_security_group_ids = ["<sg-id>"] #Security Group ID

  endpoints = {
    db1 = {
      endpoint_id         = "dms-poc-endpoint-1"
      endpoint_type       = "source"
      engine_name         = "postgres"
      database_name       = "poc"
      secrets_manager_arn = "<secret-arn>" #Source endpoint secret arn
      ssl_mode            = "require"

      postgres_settings = {
        execute_timeout = 60
      }
    }

    db2 = {
      endpoint_id         = "dms-poc-endpoint-2"
      endpoint_type       = "target"
      engine_name         = "postgres"
      database_name       = "poc_target"
      secrets_manager_arn = "<secret-arn>" #Target endpoint secret arn
      ssl_mode            = "require"
    }
  }

  replication_tasks = {
    task1 = {
      replication_task_id = "replication-task-1"
      migration_type      = "full-load" # Full load
      source_endpoint_key = "db1"       # References key in endpoints map
      target_endpoint_key = "db2"       # References key in endpoints map
      table_mappings      = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"public\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"

    }
  }
}
