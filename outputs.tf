output "aws_launch_template_id" {
  description = "The ID of the launch template."
  value       = local.ebs_no_device ? aws_launch_template.without_ebs[0].id : aws_launch_template.with_ebs[0].id
}

output "aws_launch_template_name" {
  description = "The name of the launch template."
  value       = local.ebs_no_device ? aws_launch_template.without_ebs[0].name : aws_launch_template.with_ebs[0].name
}

output "aws_autoscaling_group_id" {
  description = "The autoscaling group id."
  value       = aws_autoscaling_group.this.id
}

output "aws_autoscaling_group_arn" {
  description = " The ARN for this AutoScaling Group."
  value       = aws_autoscaling_group.this.arn
}

output "aws_autoscaling_group_name" {
  description = "The name of the autoscale group."
  value       = aws_autoscaling_group.this.name
}

output "role_node_arn" {
  description = "The ARN of IAM role ecs instance role"
  value       = aws_iam_role.node_role.arn
}

output "role_service_arn" {
  description = "The ARN of IAM role ecs service role"
  value       = aws_iam_role.service_role.arn
}
