
# scale up alarm
resource "aws_autoscaling_policy" "policy_scale_up" {
  name                   = "${var.environment}-ecs-${local.ecs_group_node}-policy-scale-up"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.alarm_scale_up_scaling_adjustment
  cooldown               = var.alarm_policy_scale_up_cool_down
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_scale_up" {
  alarm_name          = "${var.environment}-ecs-${local.ecs_group_node}-cpu-alarm-scale-up"
  alarm_description   = "This metric monitors EC2 node '${local.ecs_group_node}' of ${var.ecs_cluster_name} ECS cluster when scale up on cpu utilization."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_cpu_scale_up_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_cpu_scale_up_period
  statistic           = "Average"
  threshold           = var.alarm_cpu_scale_up_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  treat_missing_data = "notBreaching"

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.policy_scale_up.arn]

  tags = {
    Environment  = var.environment
    EcsGroupNode = var.ecs_group_node
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm_scale_up" {
  alarm_name          = "${var.environment}-ecs-${local.ecs_group_node}-memory-alarm-scale-up"
  alarm_description   = "This metric monitors EC2 node '${local.ecs_group_node}' of ${var.ecs_cluster_name} ECS cluster when scale up on memory utilization."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_memory_scale_up_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_memory_scale_up_period
  statistic           = "Average"
  threshold           = var.alarm_memory_scale_up_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  treat_missing_data = "notBreaching"

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.policy_scale_up.arn]

  tags = {
    Environment  = var.environment
    EcsGroupNode = var.ecs_group_node
  }
}

# scale down alarm
resource "aws_autoscaling_policy" "policy_scale_down" {
  name                   = "${var.environment}-ecs-${local.ecs_group_node}-policy-scale-down"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.alarm_scale_down_scaling_adjustment
  cooldown               = var.alarm_policy_scale_down_cool_down
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm_scale_down" {
  alarm_name          = "${var.environment}-ecs-${local.ecs_group_node}-memory-alarm-scale-down"
  alarm_description   = "This metric monitors EC2 node '${local.ecs_group_node}' of ${var.ecs_cluster_name} ECS cluster when scale down on memory utilization."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_memory_scale_down_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_memory_scale_down_period
  statistic           = "Average"
  threshold           = var.alarm_memory_scale_down_threshold

  treat_missing_data = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.policy_scale_down.arn]

  tags = {
    Environment  = var.environment
    EcsGroupNode = var.ecs_group_node
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_scale_down" {
  alarm_name          = "${var.environment}-ecs-${local.ecs_group_node}-cpu-alarm-scale-down"
  alarm_description   = "This metric monitors EC2 node '${local.ecs_group_node}' of ${var.ecs_cluster_name} ECS cluster when scale up on cpu utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_cpu_scale_down_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_cpu_scale_down_period
  statistic           = "Average"
  threshold           = var.alarm_cpu_scale_down_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  treat_missing_data = "notBreaching"

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.policy_scale_down.arn]

  tags = {
    Environment  = var.environment
    EcsGroupNode = var.ecs_group_node
  }
}