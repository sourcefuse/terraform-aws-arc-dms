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

  # Instance
  instance_allocated_storage            = 5
  instance_apply_immediately            = true
  instance_network_type                 = "IPV4"
  instance_class                        = "dms.t2.micro"
  instance_id                           = "DMS_POC_instance"

  # Subnet 
  subnet_group_id          = "dms_poc_subnet"
  subnet_group_description = "Subnet for DMS POC"
  subnet_group_subnet_ids  = ["", ""]


  endpoints = {
  db1 = {
    endpoint_id                     = "poc-endpoint-1"
    endpoint_type                   = "source"
    engine_name                     = "postgres"
    extra_connection_attributes     = "ssl=true"
    database_name                   = "poc_db"
    kms_key_arn                     = "arn:aws:kms:prod-region:account-id:key/prod-key-id"
    port                            = 5432
    server_name                     = ""
    ssl_mode                        = "require"
    secrets_manager_arn             = ""
    secrets_manager_access_role_arn = ""
    service_access_role             = ""
    username                        = "poc-user"

    postgres_settings = {
      capture_ddls                 = true
      database_mode                = "full"
      execute_timeout              = 60
    }
  }

  db2 = {
    endpoint_id                     = "poc-endpoint-2"
    endpoint_type                   = "target"
    engine_name                     = "postgres"
    kms_key_arn                     = "arn:aws:kms:prod-region:account-id:key/prod-key-id"
    port                            = 5432
    server_name                     = ""
    secrets_manager_arn             = ""
    secrets_manager_access_role_arn = ""
    service_access_role             = ""
    username                        = "poc-user"
  }
}


  s3_endpoints = {}

  replication_tasks = {
  task1 = {
    replication_task_id       = "replication-task-1"
    migration_type            = "full-load-and-cdc" # Full load + Change Data Capture
    source_endpoint_key       = "db1" # References key in endpoints map
    target_endpoint_key       = "db2" # References key in endpoints map
  }
}


  replication_tasks_serverless = {}
}
