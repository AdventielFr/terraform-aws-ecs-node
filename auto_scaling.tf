#----------------------
# AWS Autoscaling group configuration
#----------------------
resource "aws_autoscaling_group" "this" {
  name                      = "${var.environment}-ecs-node-${local.ecs_group_node}-asg"
  vpc_zone_identifier       = var.subnets
  min_size                  = var.asg_min
  max_size                  = var.asg_max
  desired_capacity          = var.asg_desired
  health_check_grace_period = var.asg_health_period
  launch_template {
    id      = local.ebs_no_device ? aws_launch_template.without_ebs[0].id : aws_launch_template.with_ebs[0].id
    version = "$Latest"
  }
}

#----------------------
# AWS Autoscaling policies configuration ( on scale up )
#----------------------
resource "aws_autoscaling_policy" "policy_scale_up" {
  name                   = "${var.environment}-ecs-${local.ecs_group_node}-policy-scale-up"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.alarm_scale_up_scaling_adjustment
  cooldown               = var.alarm_policy_scale_up_cool_down
  policy_type            = "SimpleScaling"
}

#----------------------
# AWS Autoscaling policies configuration ( on scale down )
#----------------------
resource "aws_autoscaling_policy" "policy_scale_down" {
  name                   = "${var.environment}-ecs-${local.ecs_group_node}-policy-scale-down"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.alarm_scale_down_scaling_adjustment
  cooldown               = var.alarm_policy_scale_down_cool_down
  policy_type            = "SimpleScaling"
}

#----------------------
# AWS Autoscaling events
#----------------------

resource "aws_cloudwatch_event_rule" "this" {
  count         = var.enable_cloudwatch_event_autoscaling
  name          = "${var.ecs_cluster_name}-${var.ecs_group_node}-autoscaling"
  description   = "Captures events from ECS cluster autoscaling ${var.ecs_cluster_name} and node group ${var.ecs_group_node}"
  event_pattern = data.template_file.cloudwatch_event_rules_autoscaling.rendered
}

resource "aws_cloudwatch_event_target" "this" {
  count     = var.enable_cloudwatch_event_autoscaling
  rule      = "${var.ecs_cluster_name}-${var.ecs_group_node}-autoscaling"
  target_id = "SendToSNS"
  arn       = aws_sns_topic.this.arn
}

data "aws_iam_policy_document" "this" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.this.arn
    ]
  }
}

#----------------------------
# SNS 
#----------------------------
resource "aws_sns_topic" "this" {
  count = var.enable_cloudwatch_event_autoscaling
  name  = "${var.ecs_cluster_name}-${var.ecs_group_node}-autoscaling-event"
  tags  = local.tags
}

resource "aws_sns_topic_policy" "default" {
  count  = var.enable_cloudwatch_event_autoscaling
  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.this.json
}