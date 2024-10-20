###########
# IAM Roles 
###########

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

# DMS <-> Redshift, S3
resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}
# DMS <-> Redshift, S3
resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms-access-for-endpoint.name
}

# DMS <-> Cloudwatch
resource "aws_iam_role" "dms-cloudwatch-logs-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-cloudwatch-logs-role"
}
# DMS <-> Cloudwatch
resource "aws_iam_role_policy_attachment" "dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role.name
}

# DMS <-> VPC
resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}
# DMS <-> VPC
resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}

######################
# Replication instance
######################

resource "aws_dms_replication_instance" "this" {
  allocated_storage            = var.instance_allocated_storage
  allow_major_version_upgrade  = var.instance_allow_major_version_upgrade
  apply_immediately            = var.instance_apply_immediately
  auto_minor_version_upgrade   = var.instance_auto_minor_version_upgrade
  availability_zone            = var.instance_availability_zone
  engine_version               = var.instance_engine_version
  kms_key_arn                  = var.instance_kms_key_arn
  multi_az                     = var.instance_multi_az
  network_type                 = var.instance_network_type
  preferred_maintenance_window = var.instance_preferred_maintenance_window
  publicly_accessible          = var.instance_publicly_accessible
  replication_instance_class   = var.instance_class 
  replication_instance_id      = var.instance_id    
  replication_subnet_group_id  = var.instance_subnet_group_id
  vpc_security_group_ids       = var.instance_vpc_security_group_ids

  tags = merge({
    Name = var.instance_id
  }, var.tags)

  depends_on = [
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
  ]
}

##########################
# Replication Subnet group
##########################

resource "aws_dms_replication_subnet_group" "this" {
  count = var.create_subnet_group ? 1 : 0

  replication_subnet_group_id          = var.subnet_group_id          
  replication_subnet_group_description = var.subnet_group_description 
  subnet_ids                           = var.subnet_group_subnet_ids  

  tags = merge(var.tags, var.subnet_group_tags)

  depends_on = [aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole]
}


#################
# DMS Certificate
#################

resource "aws_dms_certificate" "this" {
  for_each = var.certificates

  certificate_id     = each.value.certificate_id
  certificate_pem    = each.value.certificate_pem
  certificate_wallet = each.value.certificate_wallet

  tags = merge(var.tags, each.value.tags)
}


###########
# Endpoints
###########

# Fetch the secret from AWS Secrets Manager
data "aws_secretsmanager_secret" "db_secret" {
  name = var.endpoint_secret_name 
}

data "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}


resource "aws_dms_endpoint" "this" {
  for_each = var.endpoints

  certificate_arn             = aws_dms_certificate.this.certificate_arn != "" ? aws_dms_certificate.this.certificate_arn : null
  database_name               = each.value.database_name
  endpoint_id                 = each.value.endpoint_id
  endpoint_type               = each.value.endpoint_type
  engine_name                 = each.value.engine_name
  extra_connection_attributes = each.value.extra_connection_attributes
  kms_key_arn                 = each.value.kms_key_arn
  port                        = each.value.port
  server_name                 = each.value.server_name
  ssl_mode                    = each.value.ssl_mode

  # Handling Secrets Manager and Access Role conditions
  secrets_manager_access_role_arn = each.value.secrets_manager_access_role_arn
  secrets_manager_arn             = each.value.secrets_manager_arn
  service_access_role             = each.value.service_access_role
  username                        = each.value.username
  password                        = data.aws_secretsmanager_secret_version.db_secret_version.secret_string


  dynamic "postgres_settings" {
    for_each = each.value.postgres_settings != null ? [each.value.postgres_settings] : []
    content {
      after_connect_script         = postgres_settings.value.after_connect_script
      babelfish_database_name      = postgres_settings.value.babelfish_database_name
      capture_ddls                 = postgres_settings.value.capture_ddls
      database_mode                = postgres_settings.value.database_mode
      ddl_artifacts_schema         = postgres_settings.value.ddl_artifacts_schema
      execute_timeout              = postgres_settings.value.execute_timeout
      fail_tasks_on_lob_truncation = postgres_settings.value.fail_tasks_on_lob_truncation
      heartbeat_enable             = postgres_settings.value.heartbeat_enable
      heartbeat_frequency          = postgres_settings.value.heartbeat_frequency
      heartbeat_schema             = postgres_settings.value.heartbeat_schema
      map_boolean_as_boolean       = postgres_settings.value.map_boolean_as_boolean
      map_jsonb_as_clob            = postgres_settings.value.map_jsonb_as_clob
      map_long_varchar_as          = postgres_settings.value.map_long_varchar_as
      max_file_size                = postgres_settings.value.max_file_size
      plugin_name                  = postgres_settings.value.plugin_name
      slot_name                    = postgres_settings.value.slot_name
    }
  }

  dynamic "elasticsearch_settings" {
    for_each = each.value.elasticsearch_settings != null ? [each.value.elasticsearch_settings] : []
    content {
      endpoint_uri               = elasticsearch_settings.value.endpoint_uri
      error_retry_duration       = elasticsearch_settings.value.error_retry_duration
      full_load_error_percentage = elasticsearch_settings.value.full_load_error_percentage
      service_access_role_arn    = elasticsearch_settings.value.service_access_role_arn
      use_new_mapping_type       = elasticsearch_settings.value.use_new_mapping_type
    }
  }

  dynamic "kafka_settings" {
    for_each = each.value.kafka_settings != null ? [each.value.kafka_settings] : []
    content {
      broker                         = kafka_settings.value.broker
      include_control_details        = kafka_settings.value.include_control_details
      include_null_and_empty         = kafka_settings.value.include_null_and_empty
      include_partition_value        = kafka_settings.value.include_partition_value
      include_table_alter_operations = kafka_settings.value.include_table_alter_operations
      include_transaction_details    = kafka_settings.value.include_transaction_details
      message_format                 = kafka_settings.value.message_format
      message_max_bytes              = kafka_settings.value.message_max_bytes
      no_hex_prefix                  = kafka_settings.value.no_hex_prefix
      partition_include_schema_table = kafka_settings.value.partition_include_schema_table
      sasl_password                  = kafka_settings.value.sasl_password
      sasl_username                  = kafka_settings.value.sasl_username
      security_protocol              = kafka_settings.value.security_protocol
      ssl_ca_certificate_arn         = kafka_settings.value.ssl_ca_certificate_arn
      ssl_client_certificate_arn     = kafka_settings.value.ssl_client_certificate_arn
      ssl_client_key_arn             = kafka_settings.value.ssl_client_key_arn
      ssl_client_key_password        = kafka_settings.value.ssl_client_key_password
      topic                          = kafka_settings.value.topic
    }
  }

  dynamic "kinesis_settings" {
    for_each = each.value.kinesis_settings != null ? [each.value.kinesis_settings] : []
    content {
      include_control_details        = kinesis_settings.value.include_control_details
      include_null_and_empty         = kinesis_settings.value.include_null_and_empty
      include_partition_value        = kinesis_settings.value.include_partition_value
      include_table_alter_operations = kinesis_settings.value.include_table_alter_operations
      include_transaction_details    = kinesis_settings.value.include_transaction_details
      message_format                 = kinesis_settings.value.message_format
      partition_include_schema_table = kinesis_settings.value.partition_include_schema_table
      service_access_role_arn        = kinesis_settings.value.service_access_role_arn
      stream_arn                     = kinesis_settings.value.stream_arn
    }
  }

  dynamic "mongodb_settings" {
    for_each = each.value.mongodb_settings != null ? [each.value.mongodb_settings] : []
    content {
      auth_mechanism      = mongodb_settings.value.auth_mechanism
      auth_source         = mongodb_settings.value.auth_source
      auth_type           = mongodb_settings.value.auth_type
      docs_to_investigate = mongodb_settings.value.docs_to_investigate
      extract_doc_id      = mongodb_settings.value.extract_doc_id
      nesting_level       = mongodb_settings.value.nesting_level
    }
  }

  dynamic "redis_settings" {
    for_each = each.value.redis_settings != null ? [each.value.redis_settings] : []
    content {
      auth_password          = redis_settings.value.auth_password
      auth_type              = redis_settings.value.auth_type
      auth_user_name         = redis_settings.value.auth_user_name
      port                   = redis_settings.value.port
      server_name            = redis_settings.value.server_name
      ssl_ca_certificate_arn = redis_settings.value.ssl_ca_certificate_arn
      ssl_security_protocol  = redis_settings.value.ssl_security_protocol
    }
  }

  dynamic "redshift_settings" {
    for_each = each.value.redshift_settings != null ? [each.value.redshift_settings] : []
    content {
      bucket_folder                     = redshift_settings.value.bucket_folder
      bucket_name                       = redshift_settings.value.bucket_name
      encryption_mode                   = redshift_settings.value.encryption_mode
      server_side_encryption_kms_key_id = redshift_settings.value.server_side_encryption_kms_key_id
      service_access_role_arn           = redshift_settings.value.service_access_role_arn
    }
  }
}

##############
# S3 Endpoint
##############

resource "aws_dms_s3_endpoint" "this" {
  for_each = var.s3_endpoints

  certificate_arn = aws_dms_certificate.this.certificate_arn != "" ? aws_dms_certificate.this.certificate_arn : null
  endpoint_id     = each.value.endpoint_id
  endpoint_type   = each.value.endpoint_type
  kms_key_arn     = each.value.kms_key_arn
  ssl_mode        = each.value.ssl_mode

  add_column_name                             = each.value.add_column_name
  add_trailing_padding_character              = each.value.add_trailing_padding_character
  bucket_folder                               = each.value.bucket_folder
  bucket_name                                 = each.value.bucket_name
  canned_acl_for_objects                      = each.value.canned_acl_for_objects
  cdc_inserts_and_updates                     = each.value.cdc_inserts_and_updates
  cdc_inserts_only                            = each.value.cdc_inserts_only
  cdc_max_batch_interval                      = each.value.cdc_max_batch_interval
  cdc_min_file_size                           = each.value.cdc_min_file_size
  cdc_path                                    = each.value.cdc_path
  compression_type                            = each.value.compression_type
  csv_delimiter                               = each.value.csv_delimiter
  csv_no_sup_value                            = each.value.csv_no_sup_value
  csv_null_value                              = each.value.csv_null_value
  csv_row_delimiter                           = each.value.csv_row_delimiter
  data_format                                 = each.value.data_format
  data_page_size                              = each.value.data_page_size
  date_partition_delimiter                    = each.value.date_partition_delimiter
  date_partition_enabled                      = each.value.date_partition_enabled
  date_partition_sequence                     = each.value.date_partition_sequence
  date_partition_timezone                     = each.value.date_partition_timezone
  detach_target_on_lob_lookup_failure_parquet = each.value.detach_target_on_lob_lookup_failure_parquet
  dict_page_size_limit                        = each.value.dict_page_size_limit
  enable_statistics                           = each.value.enable_statistics
  encoding_type                               = each.value.encoding_type
  encryption_mode                             = each.value.encryption_mode
  expected_bucket_owner                       = each.value.expected_bucket_owner
  external_table_definition                   = each.value.external_table_definition
  glue_catalog_generation                     = each.value.glue_catalog_generation
  ignore_header_rows                          = each.value.ignore_header_rows
  include_op_for_full_load                    = each.value.include_op_for_full_load
  max_file_size                               = each.value.max_file_size
  parquet_timestamp_in_millisecond            = each.value.parquet_timestamp_in_millisecond
  parquet_version                             = each.value.parquet_version
  preserve_transactions                       = each.value.preserve_transactions
  rfc_4180                                    = each.value.rfc_4180
  row_group_length                            = each.value.row_group_length
  server_side_encryption_kms_key_id           = each.value.server_side_encryption_kms_key_id
  service_access_role_arn                     = each.value.service_access_role_arn
  timestamp_column_name                       = each.value.timestamp_column_name
  use_csv_no_sup_value                        = each.value.use_csv_no_sup_value
  use_task_start_time_for_full_load_timestamp = each.value.use_task_start_time_for_full_load_timestamp

  tags = merge(var.tags, each.value.tags)
}


##############################
# Replication Task - Instance
##############################

resource "aws_dms_replication_task" "this" {
  for_each = var.replication_tasks

  cdc_start_position        = each.value.cdc_start_position
  cdc_start_time            = each.value.cdc_start_time
  migration_type            = each.value.migration_type
  replication_instance_arn  = aws_dms_replication_instance.this[0].replication_instance_arn
  replication_task_id       = each.value.replication_task_id
  replication_task_settings = each.value.replication_task_settings
  source_endpoint_arn       = aws_dms_endpoint.this[each.value.source_endpoint_key].endpoint_arn
  start_replication_task    = each.value.start_replication_task
  table_mappings            = each.value.table_mappings
  target_endpoint_arn       = aws_dms_endpoint.this[each.value.target_endpoint_key].endpoint_arn

  tags = merge(var.tags, each.value.tags)
}


################################
# Replication Task - Serverless
################################

resource "aws_dms_replication_config" "this" {
  for_each = var.replication_tasks_serverless

  replication_config_identifier = each.value.replication_task_id
  resource_identifier           = each.value.replication_task_id

  replication_type    = each.value.migration_type
  source_endpoint_arn = each.value.source_endpoint_arn != null ? each.value.source_endpoint_arn : aws_dms_endpoint.this[each.value.source_endpoint_key].endpoint_arn
  target_endpoint_arn = each.value.target_endpoint_arn != null ? each.value.target_endpoint_arn : aws_dms_endpoint.this[each.value.target_endpoint_key].endpoint_arn
  table_mappings      = each.value.table_mappings

  replication_settings  = each.value.replication_task_settings
  supplemental_settings = each.value.supplemental_task_settings

  start_replication = each.value.start_replication_task

  compute_config {
    availability_zone            = each.value.serverless_config.availability_zone
    dns_name_servers             = each.value.serverless_config.dns_name_servers
    kms_key_id                   = each.value.serverless_config.kms_key_id
    max_capacity_units           = each.value.serverless_config.max_capacity_units
    min_capacity_units           = each.value.serverless_config.min_capacity_units
    multi_az                     = each.value.serverless_config.multi_az
    preferred_maintenance_window = each.value.serverless_config.preferred_maintenance_window
    replication_subnet_group_id  = aws_dms_replication_subnet_group.this.id
    vpc_security_group_ids       = each.value.serverless_config.vpc_security_group_ids
  }

  tags = merge(var.tags, each.value.tags)
}




######################
# Event Subscription
######################

resource "aws_dms_event_subscription" "this" {
  for_each = var.event_subscriptions

  enabled          = each.value.enabled
  event_categories = each.value.event_categories
  name             = each.value.name
  sns_topic_arn    = each.value.sns_topic_arn

  source_ids = compact(concat(
    [
      for instance in aws_dms_replication_instance.this[*] :
      instance.replication_instance_id if lookup(each.value, "instance_event_subscription_keys", null) == var.instance_id
    ],
    [
      for task in aws_dms_replication_task.this[*] :
      task.replication_task_id if contains(lookup(each.value, "task_event_subscription_keys", []), each.key)
    ]
  ))

  source_type = each.value.source_type

  tags = merge(var.tags, each.value.tags)

  timeouts {
    create = var.event_subscription_timeouts.create
    update = var.event_subscription_timeouts.update
    delete = var.event_subscription_timeouts.delete
  }
}

