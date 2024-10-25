variable "tags" {
  description = "A map of tags to use on all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

##############
# Certificate
##############

variable "create_certificate" {
  type    = bool
  default = false
}

variable "certificate" {
  type = object({
    certificate_id     = string
    certificate_pem    = optional(string, null)
    certificate_wallet = optional(string, null)
    tags               = optional(map(string), {})
  })
  default = {
    certificate_id     = "dms-poc-cert-2024"
    certificate_pem    = null
    certificate_wallet = null
    tags               = null
  }

  description = <<-EOT
  The `certificate` object defines SSL/TLS configurations for secure database migrations.
  - `certificate_id`: Unique identifier for the DMS certificate.
  - `certificate_pem`: PEM-formatted certificate string for SSL/TLS encryption.
  - `certificate_wallet`: Optional path to the certificate wallet file, used if the database requires a wallet-based certificate.
  - `tags`: Optional tags for labeling the certificate resource, allowing for better organization and management.
  EOT
}

##########
# Instance
##########


variable "instance_allocated_storage" {
  description = "The amount of storage (in gigabytes) to be initially allocated for the replication instance. Min: 5, Max: 6144, Default: 50"
  type        = number
  default     = null
}

variable "instance_auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the replication instance during the maintenance window"
  type        = bool
  default     = true
}

variable "instance_allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed"
  type        = bool
  default     = true
}

variable "instance_apply_immediately" {
  description = "Indicates whether the changes should be applied immediately or during the next maintenance window"
  type        = bool
  default     = null
}

variable "instance_availability_zone" {
  description = "The EC2 Availability Zone that the replication instance will be created in"
  type        = string
  default     = null
}

variable "instance_engine_version" {
  description = "The [engine version](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_ReleaseNotes.html) number of the replication instance"
  type        = string
  default     = null
}

variable "instance_kms_key_arn" {
  description = "The Amazon Resource Name (ARN) for the KMS key that will be used to encrypt the connection parameters"
  type        = string
  default     = null
}

variable "instance_multi_az" {
  description = "Specifies if the replication instance is a multi-az deployment. You cannot set the `availability_zone` parameter if the `multi_az` parameter is set to `true`"
  type        = bool
  default     = null
}

variable "instance_network_type" {
  description = "The type of IP address protocol used by a replication instance. Valid values: IPV4, DUAL"
  type        = string
  default     = null
}

variable "instance_preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC)"
  type        = string
  default     = null
}

variable "instance_publicly_accessible" {
  description = "Specifies the accessibility options for the replication instance"
  type        = bool
  default     = null
}

variable "instance_class" {
  description = "The compute and memory capacity of the replication instance as specified by the replication instance class"
  type        = string
  default     = "dms.t2.micro"
}

variable "instance_id" {
  description = "The replication instance identifier. This parameter is stored as a lowercase string"
  type        = string
  default     = "dms-instance"
}

variable "instance_subnet_group_id" {
  description = "An existing subnet group to associate with the replication instance"
  type        = string
  default     = null
}

variable "instance_vpc_security_group_ids" {
  description = "A list of VPC security group IDs to be used with the replication instance"
  type        = list(string)
  default     = null
}


###############
# Subnet group
###############

variable "create_subnet_group" {
  description = "Determines whether the replication subnet group will be created"
  type        = bool
  default     = true
}

variable "subnet_group_description" {
  description = "The description for the subnet group"
  type        = string
  default     = "DMS Replication subnet group"
}

variable "subnet_group_id" {
  description = "The name for the replication subnet group. Stored as a lowercase string, must contain no more than 255 alphanumeric characters, periods, spaces, underscores, or hyphens"
  type        = string
  default     = "DMS_replication_subnet_group"
}

variable "subnet_group_subnet_ids" {
  description = "A list of the EC2 subnet IDs for the subnet group"
  type        = list(string)
  default     = []
}

variable "subnet_group_tags" {
  description = "A map of additional tags to apply to the replication subnet group"
  type        = map(string)
  default     = {}
}

############
# Endpoints
############

variable "endpoints" {
  type = map(object({
    endpoint_id                     = string
    endpoint_type                   = string
    engine_name                     = string
    extra_connection_attributes     = optional(string)
    database_name                   = optional(string)
    kms_key_arn                     = optional(string)
    port                            = optional(number)
    server_name                     = optional(string)
    ssl_mode                        = optional(string)
    secrets_manager_arn             = optional(string)
    secrets_manager_access_role_arn = optional(string)
    service_access_role             = optional(string)
    username                        = optional(string)

    # postgres settings
    postgres_settings = optional(object({
      after_connect_script         = optional(string)
      babelfish_database_name      = optional(string)
      capture_ddls                 = optional(bool)
      database_mode                = optional(string)
      ddl_artifacts_schema         = optional(string)
      execute_timeout              = optional(number)
      fail_tasks_on_lob_truncation = optional(bool)
      heartbeat_enable             = optional(bool)
      heartbeat_frequency          = optional(number)
      heartbeat_schema             = optional(string)
      map_boolean_as_boolean       = optional(bool)
      map_jsonb_as_clob            = optional(bool)
      map_long_varchar_as          = optional(string)
      max_file_size                = optional(number)
      plugin_name                  = optional(string)
      slot_name                    = optional(string)
    }))

    # elasticsearch settings
    elasticsearch_settings = optional(object({
      endpoint_uri               = optional(string)
      error_retry_duration       = optional(number)
      full_load_error_percentage = optional(number)
      service_access_role_arn    = optional(string)
      use_new_mapping_type       = optional(bool)
    }))

    # kafka settings
    kafka_settings = optional(object({
      broker                         = optional(string)
      include_control_details        = optional(bool)
      include_null_and_empty         = optional(bool)
      include_partition_value        = optional(bool)
      include_table_alter_operations = optional(bool)
      include_transaction_details    = optional(bool)
      message_format                 = optional(string)
      message_max_bytes              = optional(number)
      no_hex_prefix                  = optional(bool)
      partition_include_schema_table = optional(bool)
      sasl_password                  = optional(string)
      sasl_username                  = optional(string)
      security_protocol              = optional(string)
      ssl_ca_certificate_arn         = optional(string)
      ssl_client_certificate_arn     = optional(string)
      ssl_client_key_arn             = optional(string)
      ssl_client_key_password        = optional(string)
      topic                          = optional(string)
    }))

    # kinesis settings
    kinesis_settings = optional(object({
      include_control_details        = optional(bool)
      include_null_and_empty         = optional(bool)
      include_partition_value        = optional(bool)
      include_table_alter_operations = optional(bool)
      include_transaction_details    = optional(bool)
      message_format                 = optional(string)
      partition_include_schema_table = optional(bool)
      service_access_role_arn        = optional(string)
      stream_arn                     = optional(string)
    }))

    # mongodb settings
    mongodb_settings = optional(object({
      auth_mechanism      = optional(string)
      auth_source         = optional(string)
      auth_type           = optional(string)
      docs_to_investigate = optional(number)
      extract_doc_id      = optional(bool)
      nesting_level       = optional(number)
    }))

    # redis settings
    redis_settings = optional(object({
      auth_password          = optional(string)
      auth_type              = optional(string)
      auth_user_name         = optional(string)
      port                   = optional(number)
      server_name            = optional(string)
      ssl_ca_certificate_arn = optional(string)
      ssl_security_protocol  = optional(string)
    }))

    # redshift settings
    redshift_settings = optional(object({
      bucket_folder                     = optional(string)
      bucket_name                       = optional(string)
      encryption_mode                   = optional(string)
      server_side_encryption_kms_key_id = optional(string)
      service_access_role_arn           = optional(string)
    }))

  }))

  default = {}

  description = <<-EOT
  Map of endpoint configurations.
  - `database_name`: Name of the database to connect to.
  - `endpoint_id`: Unique identifier for the endpoint.
  - `endpoint_type`: Type of endpoint, either "source" or "target".
  - `engine_name`: Name of the database engine (e.g., "mysql", "postgres").
  - `extra_connection_attributes`: Optional additional connection attributes.
  - `kms_key_arn`: ARN of the AWS KMS key for encryption.
  - `port`: Port on which the database server is listening.
  - `server_name`: Hostname or IP address of the database server.
  - `ssl_mode`: SSL mode for secure connections (e.g., "require", "disable").
  - `service_access_role`: IAM role for accessing AWS services like S3.
  - `secrets_manager_arn`: ARN for AWS Secrets Manager for connection credentials.
  - `secrets_manager_access_role_arn`: ARN for the role to access AWS Secrets Manager.

  **Database-specific settings**:
  - `postgres_settings`: Configuration for PostgreSQL databases.
  - `elasticsearch_settings`: Configuration for Elasticsearch databases.
  - `kafka_settings`: Configuration for Kafka message broker.
  - `kinesis_settings`: Configuration for Kinesis stream settings.
  - `mongodb_settings`: Configuration for MongoDB databases.
  - `redis_settings`: Configuration for Redis data store.
  - `redshift_settings`: Configuration for Redshift databases.

  Each database type's settings include unique options for connection, security, and customization based on the engine used.
  EOT
}

##############
# S3 Endpoint
##############

variable "s3_endpoints" {
  type = map(object({
    endpoint_id                                 = string
    endpoint_type                               = string
    kms_key_arn                                 = optional(string)
    ssl_mode                                    = optional(string)
    add_column_name                             = optional(bool)
    add_trailing_padding_character              = optional(bool)
    bucket_folder                               = optional(string)
    bucket_name                                 = string
    canned_acl_for_objects                      = optional(string)
    cdc_inserts_and_updates                     = optional(bool)
    cdc_inserts_only                            = optional(bool)
    cdc_max_batch_interval                      = optional(number)
    cdc_min_file_size                           = optional(number)
    cdc_path                                    = optional(string)
    compression_type                            = optional(string)
    csv_delimiter                               = optional(string)
    csv_no_sup_value                            = optional(bool)
    csv_null_value                              = optional(string)
    csv_row_delimiter                           = optional(string)
    data_format                                 = optional(string)
    data_page_size                              = optional(number)
    date_partition_delimiter                    = optional(string)
    date_partition_enabled                      = optional(bool)
    date_partition_sequence                     = optional(string)
    date_partition_timezone                     = optional(string)
    detach_target_on_lob_lookup_failure_parquet = optional(bool)
    dict_page_size_limit                        = optional(number)
    enable_statistics                           = optional(bool)
    encoding_type                               = optional(string)
    encryption_mode                             = optional(string)
    expected_bucket_owner                       = optional(string)
    external_table_definition                   = optional(string)
    glue_catalog_generation                     = optional(bool)
    ignore_header_rows                          = optional(bool)
    include_op_for_full_load                    = optional(bool)
    max_file_size                               = optional(number)
    parquet_timestamp_in_millisecond            = optional(bool)
    parquet_version                             = optional(string)
    preserve_transactions                       = optional(bool)
    rfc_4180                                    = optional(bool)
    row_group_length                            = optional(number)
    server_side_encryption_kms_key_id           = optional(string)
    service_access_role_arn                     = string
    timestamp_column_name                       = optional(string)
    use_csv_no_sup_value                        = optional(bool)
    use_task_start_time_for_full_load_timestamp = optional(bool)
    tags                                        = optional(map(string))
  }))

  default = {}

  description = <<-EOT
  Map of S3 Endpoints.
  - `endpoint_id`: Unique identifier for the endpoint.
  - `endpoint_type`: Specifies the type of endpoint. Valid values are 'source' and 'target'.
  - `kms_key_arn`: ARN of the KMS key used for encryption at rest.
  - `ssl_mode`: SSL mode for data transfer; options may include 'require', 'verify-ca', etc.
  - `add_column_name`: Whether to add column name information to the .csv output file.
  - `add_trailing_padding_character`: Whether to add padding. Default is false.
  - `bucket_folder`: S3 object prefix.
  - `bucket_name`: Name of the target S3 bucket.
  - `canned_acl_for_objects`: Canned ACL to apply to each uploaded object (e.g., "private", "public-read").
  - `cdc_inserts_and_updates`: Enables CDC with both inserts and updates.
  - `cdc_inserts_only`: Enables CDC with inserts only, excluding updates.
  - `cdc_max_batch_interval`: Maximum interval (in seconds) for CDC batch files.
  - `cdc_min_file_size`: Minimum file size condition as defined in kilobytes to output a file to Amazon S3.
  - `cdc_path`: (Required for CDC; otherwise, Optional) Folder path of CDC files.
  - `compression_type`: Compression type for files (e.g., "GZIP", "NONE").
  - `csv_delimiter`: Delimiter character for CSV files.
  - `csv_no_sup_value`: Whether to omit supplementary values in CSV files.
  - `csv_null_value`: Null value replacement in CSV files.
  - `csv_row_delimiter`: Row delimiter for CSV files.
  - `data_format`: Format for data in the S3 bucket; possible values could include "csv", "parquet", etc.
  - `data_page_size`: Size of one data page in bytes.(AWS default is 1 MiB)
  - `date_partition_delimiter`: Delimiter for date-based partitions. Valid values are "SLASH", "UNDERSCORE", "DASH", "NONE"
  - `date_partition_enabled`: Enables date partitioning of data in S3.
  - `date_partition_sequence`: Sequence for date partitions (e.g., "YYYYMMDD").
  - `date_partition_timezone`: Time zone for date partitioning.
  - `detach_target_on_lob_lookup_failure_parquet`: Undocumented argument for use as directed by AWS Support.
  - `dict_page_size_limit`: Maximum size in bytes of an encoded dictionary page of a column. (AWS default is 1 MiB)
  - `enable_statistics`: Enables statistics for data files.
  - `encoding_type`: Encoding type for data; possible values could include "plain", "dictionary" or "rle_dictionary".
  - `encryption_mode`: Specifies encryption mode; could be "SSE-KMS" or "SSE-S3".
  - `expected_bucket_owner`: Bucket owner to prevent sniping. Value is an AWS account ID.
  - `external_table_definition`: (Required for source endpoints; otherwise, Optional) JSON document that describes how AWS DMS should interpret the data.
  - `glue_catalog_generation`: Enables the automatic generation of AWS Glue catalog tables.
  - `ignore_header_rows`: Skips header rows in CSV files if set to true.
  - `include_op_for_full_load`: Includes DMS operation types in the full load.
  - `max_file_size`: Maximum size (in KB) of any .csv file to be created while migrating to an S3 target during full load.
  - `parquet_timestamp_in_millisecond`: Uses milliseconds for timestamps in Parquet files.
  - `parquet_version`: Parquet file version to use; could be "parquet-1-0" or "parquet-2-0".
  - `preserve_transactions`: Preserves transactions during migration.
  - `rfc_4180`: Ensures compatibility with RFC4180 for CSV files.
  - `row_group_length`: Number of rows per row group in Parquet files.
  - `server_side_encryption_kms_key_id`: KMS key ID for server-side encryption of files.
  - `service_access_role_arn`: IAM role ARN granting DMS access to the S3 bucket.
  - `timestamp_column_name`: Column name to use for timestamps.
  - `use_csv_no_sup_value`: Whether to use a CSV file without supplementary values.
  - `use_task_start_time_for_full_load_timestamp`: Uses task start time as the timestamp for full load.
  - `tags`: Tags to assign to the endpoint resource.
  EOT
}



###################
# Replication Task
###################

variable "replication_tasks" {
  type = map(object({
    replication_task_id       = string
    migration_type            = string
    cdc_start_position        = optional(string)
    cdc_start_time            = optional(string)
    source_endpoint_arn       = string
    target_endpoint_arn       = string
    replication_task_settings = optional(string)
    resource_identifier       = optional(string)
    start_replication_task    = optional(bool)
    table_mappings            = string
    tags                      = optional(map(string))
  }))

  default = {}

  description = <<-EOT
  Map of replication tasks.
  - `replication_task_id`: Unique identifier for the replication task.
  - `migration_type`: Type of migration to perform: "full-load", "cdc" (change data capture), or "full-load-and-cdc".
  - `cdc_start_position`: Specific start position for CDC; usually a log sequence or timestamp to begin CDC.
  - `cdc_start_time`: Conflicts with cdc_start_position) RFC3339 formatted date string or UNIX timestamp for the start of the Change Data Capture (CDC) operation.
  - `source_endpoint_arn`: ARN that uniquely identifies the source endpoint.
  - `target_endpoint_arn`: ARN that uniquely identifies the target endpoint.
  - `replication_task_settings`: JSON configuration for additional task settings, such as batch size and logging.
  - `resource_identifier`: A friendly name for the resource identifier at the end of the EndpointArn response parameter that is returned in the created Endpoint object.
  - `start_replication_task`: Boolean to auto-start the task upon creation.
  - `table_mappings`: Escaped JSON string that contains the table mappings.
  - `tags`: Tags for labeling the replication task resource.
  EOT
}


variable "replication_tasks_serverless" {
  type = map(object({
    replication_task_id        = string
    migration_type             = string
    source_endpoint_arn        = optional(string)
    target_endpoint_arn        = optional(string)
    table_mappings             = optional(string)
    resource_identifier        = optional(string)
    replication_task_settings  = optional(map(string))
    supplemental_task_settings = optional(map(string))
    start_replication_task     = optional(bool)
    serverless_config = optional(object({
      availability_zone            = optional(string)
      dns_name_servers             = optional(list(string))
      kms_key_id                   = optional(string)
      max_capacity_units           = number
      min_capacity_units           = optional(number)
      multi_az                     = optional(bool)
      preferred_maintenance_window = optional(string)
      vpc_security_group_ids       = optional(list(string))
    }))
    tags = optional(map(string))
  }))

  default = {}

  description = <<-EOT
  Map of serverless replication tasks
  Map of replication tasks.
  - `replication_task_id`: Unique identifier for the replication task.
  - `migration_type`: Type of migration to perform: "full-load", "cdc" (change data capture), or "full-load-and-cdc".
  - `source_endpoint_arn`: ARN that uniquely identifies the source endpoint.
  - `target_endpoint_arn`: ARN that uniquely identifies the target endpoint.
  - `table_mappings`: Escaped JSON string that contains the table mappings.
  - `resource_identifier`: A friendly name for the resource identifier at the end of the EndpointArn response parameter that is returned in the created Endpoint object.
  - `replication_task_settings`: JSON configuration for additional task settings, such as batch size and logging.
  - `supplemental_task_settings`: JSON settings for specifying supplemental data.
  - `start_replication_task`: Boolean to auto-start the task upon creation.
  - `serverless_config`: Configuration block for provisioning an DMS Serverless replication.
  - `tags`: Tags for labeling the replication task resource.
  EOT
}


#####################
# Event Subscription
#####################

variable "event_subscriptions" {
  type = map(object({
    enabled          = optional(bool, true)
    event_categories = optional(list(string), [])
    name             = string
    sns_topic_arn    = string
    source_ids       = optional(string, "")
    source_type      = optional(string, null)
    tags             = optional(map(string), {})
  }))
  default     = {}
  description = <<-EOT
  Map of objects that define the event subscriptions to be created.
  - `event_categories`: List of event categories to listen for.
  - `name`: The name of the event subscription.
  - `sns_topic_arn`: The ARN of the SNS topic to receive notifications for the event subscription.
  - `source_ids`: Ids of sources to listen to.
  - `source_type`: Type of source for events. Valid values `replication-instance` or `replication-task`.
  - `tags`: Tags to assign to the event subscription resource.
  EOT
}

variable "event_subscription_timeouts" {
  description = "A map of timeouts for event subscription create/update/delete operations"
  type        = map(string)
  default = {
    create = "1m"
    update = "1m"
    delete = "1m"
  }
}
