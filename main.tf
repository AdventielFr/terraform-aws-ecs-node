#----------------------
# AWS Launch Template configuration ( with EBS attachment )
#----------------------
resource "aws_launch_template" "with_ebs" {
  count                  = local.ebs_no_device ? 0 : 1
  name                   = "${var.environment}-ecs-node-${local.ecs_group_node}-lt"
  image_id               = local.aws_ami
  description            = "Launch template for EC2 node '${local.ecs_group_node}' of ${var.ecs_cluster_name} ECS cluster."
  vpc_security_group_ids = var.instance_security_groups
  user_data              = base64encode(local.user_data_aws)
  instance_type          = var.instance_type
  key_name               = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  block_device_mappings {
    device_name = local.ebs_device
    no_device   = local.ebs_no_device
    ebs {
      volume_size           = var.ebs_volume_size
      encrypted             = var.ebs_kms_key_id != ""
      kms_key_id            = var.ebs_kms_key_id
      volume_type           = var.ebs_volume_type
      delete_on_termination = var.ebs_delete_on_termination
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name         = "${var.environment}-ecs-node-${local.ecs_group_node}-lt"
    Environment  = var.environment
    EcsGroupNode = var.ecs_group_node
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name         = "${var.environment}-ecs-node-${local.ecs_group_node}"
      Environment  = var.environment
      EcsGroupNode = local.ecs_group_node
    }
  }

  monitoring {
    enabled = var.enable_monitoring
  }
  ebs_optimized = var.ebs_optimized

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
  }

}

#----------------------
# AWS Launch Template configuration ( without EBS attachment )
#----------------------
resource "aws_launch_template" "without_ebs" {
  count                  = local.ebs_no_device ? 1 : 0
  name                   = "${var.environment}-ecs-node-${local.ecs_group_node}-lt"
  image_id               = local.aws_ami
  description            = "Launch template for EC2 node '${local.ecs_group_node}' of ${var.ecs_cluster_name} ECS cluster."
  vpc_security_group_ids = var.instance_security_groups
  user_data              = base64encode(local.user_data_aws)
  instance_type          = var.instance_type
  key_name               = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name         = "${var.environment}-ecs-node-${local.ecs_group_node}-lt"
    Environment  = var.environment
    EcsGroupNode = var.ecs_group_node
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name         = "${var.environment}-ecs-node-${local.ecs_group_node}"
      Environment  = var.environment
      EcsGroupNode = local.ecs_group_node
    }
  }

  monitoring {
    enabled = var.enable_monitoring
  }
  ebs_optimized = var.ebs_optimized

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
  }
}

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
