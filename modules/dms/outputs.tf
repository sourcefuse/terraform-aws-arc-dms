################################################################################
# IAM Roles
################################################################################

# DMS Endpoint
output "dms_access_for_endpoint_iam_role_arn" {
  description = "ARN specifying the role"
  value       = aws_iam_role.dms-access-for-endpoint.arn
}

output "dms_access_for_endpoint_iam_role_id" {
  description = "Name of the IAM role"
  value       = aws_iam_role.dms-access-for-endpoint.id
}

output "dms_access_for_endpoint_iam_role_unique_id" {
  description = "Stable and unique string identifying the role"
  value       = aws_iam_role.dms-access-for-endpoint.unique_id
}


###############
# Subnet group
###############

output "replication_subnet_group_id" {
  description = "The ID of the subnet group"
  value       = var.create_subnet_group ? aws_dms_replication_subnet_group.this[0].id : null

}

###########
# Instance
###########

output "replication_instance_arn" {
  description = "The Amazon Resource Name (ARN) of the replication instance"
  value       = aws_dms_replication_instance.this.replication_instance_arn
}

output "replication_instance_private_ips" {
  description = "A list of the private IP addresses of the replication instance"
  value       = aws_dms_replication_instance.this.replication_instance_private_ips
}

output "replication_instance_public_ips" {
  description = "A list of the public IP addresses of the replication instance"
  value       = aws_dms_replication_instance.this.replication_instance_public_ips
}

output "replication_instance_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider `default_tags` configuration block"
  value       = aws_dms_replication_instance.this.tags_all
}

###########
# Endpoint
###########

output "endpoints" {
  description = "A map of maps containing the endpoints created and their full output of attributes and values"
  value       = var.endpoints != null ? aws_dms_endpoint.this : {}
  sensitive   = true
}

##############
# S3 Endpoint
##############

output "s3_endpoints" {
  description = "A map of maps containing the S3 endpoints created and their full output of attributes and values"
  value       = var.s3_endpoints != null ? aws_dms_s3_endpoint.this : {}
  sensitive   = true
}

###################
# Replication Task
###################

output "replication_tasks" {
  description = "A map of maps containing the replication tasks created and their full output of attributes and values"
  value       = var.replication_tasks != null ? aws_dms_replication_task.this : {}
}

output "serverless_replication_tasks" {
  description = "A map of maps containing the serverless replication tasks (replication_config) created and their full output of attributes and values"
  value       = var.replication_tasks_serverless != null ? aws_dms_replication_config.this : {}
}

#####################
# Event Subscription
#####################

output "event_subscriptions" {
  description = "A map of maps containing the event subscriptions created and their full output of attributes and values"
  value       = var.event_subscriptions != null ? aws_dms_event_subscription.this : {}
}

################
# Certificate
################

output "certificates" {
  description = "A map of maps containing the certificates created and their full output of attributes and values"
  value       = var.certificate != null ? aws_dms_certificate.this : null
  sensitive   = true
}
