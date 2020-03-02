output "aws_launch_template_id" {
  description = "The ID of the launch template."
  value       = module.ecs_cluster.aws_launch_template_id
}

output "aws_launch_template_name" {
  description = "The name of the launch template."
  value       = module.ecs_cluster.aws_launch_template_name
}

output "aws_autoscaling_group_id" {
  description = "The autoscaling group id."
  value       = module.ecs_cluster.aws_autoscaling_group_id
}

output "aws_autoscaling_group_arn" {
  description = " The ARN for this AutoScaling Group."
  value       = module.ecs_cluster.aws_autoscaling_group_arn
}

output "aws_autoscaling_group_name" {
  description = "The name of the autoscale group."
  value       = module.ecs_cluster.aws_autoscaling_group_name
}

output "role_node_arn" {
  description = "The ARN of IAM role ecs instance role"
  value       = module.ecs_cluster.role_node_arn
}

output "role_service_arn" {
  description = "The ARN of IAM role ecs service role"
  value       = module.ecs_cluster.role_service_arn
}
