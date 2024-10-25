################################################################################
# IAM Roles
################################################################################

# DMS Endpoint
output "dms_access_for_endpoint_iam_role_arn" {
  description = "ARN specifying the role"
  value       = module.aws_dms.dms_access_for_endpoint_iam_role_arn
}

output "dms_access_for_endpoint_iam_role_id" {
  description = "Name of the IAM role"
  value       = module.aws_dms.dms_access_for_endpoint_iam_role_id
}

output "dms_access_for_endpoint_iam_role_unique_id" {
  description = "Stable and unique string identifying the role"
  value       = module.aws_dms.dms_access_for_endpoint_iam_role_unique_id
}


###############
# Subnet group
###############

output "replication_subnet_group_id" {
  description = "The ID of the subnet group"
  value       = module.aws_dms.replication_subnet_group_id

}

###########
# Instance
###########

output "replication_instance_arn" {
  description = "The Amazon Resource Name (ARN) of the replication instance"
  value       = module.aws_dms.replication_instance_arn
}

output "replication_instance_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider `default_tags` configuration block"
  value       = module.aws_dms.replication_instance_tags_all
}

###########
# Endpoint
###########

output "endpoints" {
  description = "A map of maps containing the endpoints created and their full output of attributes and values"
  value       = module.aws_dms.endpoints
  sensitive   = true
}

##############
# S3 Endpoint
##############

output "s3_endpoints" {
  description = "A map of maps containing the S3 endpoints created and their full output of attributes and values"
  value       = module.aws_dms.s3_endpoints
  sensitive   = true
}

###################
# Replication Task
###################

output "replication_tasks" {
  description = "A map of maps containing the replication tasks created and their full output of attributes and values"
  value       = module.aws_dms.replication_tasks
}

output "serverless_replication_tasks" {
  description = "A map of maps containing the serverless replication tasks (replication_config) created and their full output of attributes and values"
  value       = module.aws_dms.serverless_replication_tasks
}

#####################
# Event Subscription
#####################

output "event_subscriptions" {
  description = "A map of maps containing the event subscriptions created and their full output of attributes and values"
  value       = module.aws_dms.event_subscriptions
}

################
# Certificate
################

output "certificates" {
  description = "A map of maps containing the certificates created and their full output of attributes and values"
  value       = module.aws_dms.certificates
  sensitive   = true
}
