output "replication_instance_arn" {
  description = "The Amazon Resource Name (ARN) of the replication instance"
  value       = module.aws_dms.replication_instance_arn
}
