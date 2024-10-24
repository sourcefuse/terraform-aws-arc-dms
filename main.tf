# AWS DMS

module "aws_dms" {
  source = "./modules/dms"

  # Instance
  instance_allocated_storage            = var.instance_allocated_storage
  instance_apply_immediately            = var.instance_apply_immediately
  instance_allow_major_version_upgrade  = var.instance_allow_major_version_upgrade
  instance_auto_minor_version_upgrade   = var.instance_auto_minor_version_upgrade
  instance_availability_zone            = var.instance_availability_zone
  instance_engine_version               = var.instance_engine_version
  instance_kms_key_arn                  = var.instance_kms_key_arn
  instance_multi_az                     = var.instance_multi_az
  instance_network_type                 = var.instance_network_type
  instance_preferred_maintenance_window = var.instance_preferred_maintenance_window
  instance_publicly_accessible          = var.instance_publicly_accessible
  instance_class                        = var.instance_class
  instance_id                           = var.instance_id
  instance_subnet_group_id              = var.instance_subnet_group_id
  instance_vpc_security_group_ids       = var.instance_vpc_security_group_ids

  # Subnet
  create_subnet_group      = var.create_subnet_group
  subnet_group_id          = var.subnet_group_id
  subnet_group_description = var.subnet_group_description
  subnet_group_subnet_ids  = var.subnet_group_subnet_ids
  subnet_group_tags        = var.subnet_group_tags

  endpoints = var.endpoints

  replication_tasks = var.replication_tasks

  replication_tasks_serverless = var.replication_tasks_serverless

  s3_endpoints = var.s3_endpoints
}
