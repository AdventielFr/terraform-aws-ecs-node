#----------------------
# data
#----------------------

data "aws_caller_identity" "current" {}

data "aws_ami" "aws_optimized_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
  
  owners = ["amazon"]
}

data "aws_iam_policy_document" "service_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "node_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "template_file" "user_data_efs_option_tpl" {
  template = "${file("${path.module}/templates/user-data-opt-efs.tpl")}"

  vars = {
    efs_mount_point = var.efs_mount_point
    efs_volume = var.efs_volume
  }
}

data "template_file" "user_data_cloudwath_agent_option_tpl" {
  template = "${file("${path.module}/templates/user-data-opt-cloudwatch-agent.tpl")}"

  vars = {
    region = var.aws_region
    cloudwatch_agent_config_content = local.cloudwatch_agent_config_content
  }
}

data "template_file" "cloudwatch_agent_configuration_minimal_tpl" {
  template = "${file("${path.module}/templates/cloudwatch_agent_configuration_minimal.tpl")}"

  vars = {
    metrics_collection_interval = var.cloudwatch_agent_metrics_collection_interval
    disk_resources = jsonencode(var.cloudwatch_agent_metrics_disk_resources)
    cpu_resources = var.cloudwatch_agent_metrics_cpu_resources
 }

}

data "template_file" "cloudwatch_agent_configuration_standard_tpl" {
  template = "${file("${path.module}/templates/cloudwatch_agent_configuration_standard.tpl")}"

  vars = {
    metrics_collection_interval = var.cloudwatch_agent_metrics_collection_interval
    disk_resources = jsonencode(var.cloudwatch_agent_metrics_disk_resources)
    cpu_resources = var.cloudwatch_agent_metrics_cpu_resources
 }

}

data "template_file" "cloudwatch_agent_configuration_advanced_tpl" {
  template = "${file("${path.module}/templates/cloudwatch_agent_configuration_advanced.tpl")}"

  vars = {
    metrics_collection_interval = var.cloudwatch_agent_metrics_collection_interval
    disk_resources = jsonencode(var.cloudwatch_agent_metrics_disk_resources)
    cpu_resources = var.cloudwatch_agent_metrics_cpu_resources
  }
}

data "template_file" "user_data_tpl" {
  template = "${file("${path.module}/templates/user-data.tpl")}"

  vars = {
    environment = var.environment
    ecs_cluster_name = var.ecs_cluster_name
    ecs_group_node = local.ecs_group_node
    aws_region = var.aws_region
    ecs_agent_loglevel = var.ecs_agent_loglevel
    ecs_image_pull_behavior = var.ecs_image_pull_behavior
    ecs_group_node = local.ecs_group_node
    ecs_enable_task_iam_role = var.ecs_enable_task_iam_role
    ecs_enable_task_iam_role_network_host = var.ecs_enable_task_iam_role_network_host
    ecs_disable_image_cleanup=var.ecs_disable_image_cleanup
    ecs_image_cleanup_interval=var.ecs_image_cleanup_interval
    ecs_image_minimum_cleanup_age=var.ecs_image_minimum_cleanup_age
    ecs_num_images_delete_per_cycle=var.ecs_num_images_delete_per_cycle
    ecs_container_stop_timeout=var.ecs_container_stop_timeout
    ecs_container_start_timeout=var.ecs_container_start_timeout
    ecs_enable_spot_instance_draining=var.ecs_enable_spot_instance_draining
    ecs_disable_privileged=var.ecs_disable_privileged
    ecs_selinux_capable=var.ecs_selinux_capable
    ecs_apparmor_capable=var.ecs_selinux_capable
    ecs_engine_task_cleanup_wait_duration=var.ecs_engine_task_cleanup_wait_duration
    ecs_enable_task_eni=var.ecs_enable_task_eni
    ecs_http_proxy=local.ecs_http_proxy
    ecs_no_proxy=local.ecs_no_proxy
    ecs_cni_plugins_path=var.ecs_cni_plugins_path
    ecs_disable_docker_health_check=var.ecs_disable_docker_health_check
    cron_definition_restart_ecs_demon = var.cron_definition_restart_ecs_demon 
    user_data_option_efs = local.user_data_option_efs
    user_data_option_cloudwatch_agent = local.user_data_option_cloudwatch_agent
  }
}

data "template_file" "node_role_policy_tpl" {
  template = "${file("${path.module}/templates/node-role-policy.tpl")}"
}

data "template_file" "service_role_policy_tpl" {
  template = "${file("${path.module}/templates/service-role-policy.tpl")}"
}

#----------------------
# locals
#----------------------
locals {
  aws_ami_userdefined = "${lookup(var.ecs_optimized_amis, var.aws_region, "")}"
  aws_ami             = "${local.aws_ami_userdefined == "" ? data.aws_ami.aws_optimized_ecs.id : local.aws_ami_userdefined}"
  user_data_aws       = "${var.user_data == "" ? data.template_file.user_data_tpl.rendered : var.user_data}"
  ecs_group_node      = var.ecs_group_node == "" ? "default": var.ecs_group_node
  ecs_http_proxy      = var.ecs_http_proxy != "" ? "echo HTTP_PROXY=${var.ecs_http_proxy} >> /etc/ecs/ecs.config" : ""
  ecs_no_proxy        = var.ecs_no_proxy != "" ? "echo NO_PROXY=${var.ecs_no_proxy} >> /etc/ecs/ecs.config" : ""
  cloudwatch_agent_config_content = var.cloudwatch_agent_metrics_config == "minimal" ? data.template_file.cloudwatch_agent_configuration_minimal_tpl.rendered : (var.cloudwatch_agent_metrics_config == "custom" ? var.cloudwatch_agent_metrics_custom_config_content : (var.cloudwatch_agent_metrics_config == "standard" ? data.template_file.cloudwatch_agent_configuration_standard_tpl.rendered : ( var.cloudwatch_agent_metrics_config == "advanced" ? data.template_file.cloudwatch_agent_configuration_advanced_tpl.rendered: "")))
  user_data_option_efs = var.efs_volume == "" ? "" : data.template_file.user_data_efs_option_tpl.rendered
  user_data_option_cloudwatch_agent = local.cloudwatch_agent_config_content == "" ? "" : data.template_file.user_data_cloudwath_agent_option_tpl.rendered
}

#----------------------
# resources
#----------------------

# launch template
resource "aws_launch_template" "this" {
  name                    = "${var.environment}-ecs-node-${local.ecs_group_node}-lt"
  image_id                = local.aws_ami
  description             = "Launch template for EC2 node '${local.ecs_group_node}' of ${var.ecs_cluster_name} ECS cluster."
  vpc_security_group_ids  = var.instance_security_groups
  user_data               = base64encode(local.user_data_aws)
  instance_type           = var.instance_type
  key_name                = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  } 

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.environment}-ecs-node-${local.ecs_group_node}-lt"
    Environment = var.environment
    EcsGroupNode = var.ecs_group_node
  }

  tag_specifications {
     resource_type = "instance"
     tags = {
       Name = "${var.environment}-ecs-node-${local.ecs_group_node}"
       Environment = var.environment
       EcsGroupNode = local.ecs_group_node
     }
  }

  monitoring {
    enabled = var.enable_monitoring
  }

} 

# auto scaling group
resource "aws_autoscaling_group" "this" {
  name                      = "${var.environment}-ecs-node-${local.ecs_group_node}-asg"
  vpc_zone_identifier       = var.subnets
  min_size                  = var.asg_min
  max_size                  = var.asg_max
  desired_capacity          = var.asg_desired
  health_check_grace_period = var.asg_health_period
  launch_template {
    id      = "${aws_launch_template.this.id}"
    version = "$Latest"
  }
}

# iam ec2 cluster node role
resource "aws_iam_role" "node_role" {
  name               = "${var.environment}-ecs-node-${local.ecs_group_node}-role"
  description        = "Role to enable to manage EC2 node '${local.ecs_group_node}' of ${var.ecs_cluster_name} ECS cluster."
  assume_role_policy = data.aws_iam_policy_document.node_role.json
 
  tags = {
    Name        = "${var.environment}-ecs-node-${local.ecs_group_node}-role"
    Environment = var.environment
    EcsGroupNode   = local.ecs_group_node
  }
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_attachment_1" {
    role       = "${aws_iam_role.node_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_attachment_2" {
    role       = "${aws_iam_role.node_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_attachment_3" {
    count      = var.cloudwatch_agent_metrics_config != "" ? 1: 0
    role       = "${aws_iam_role.node_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy" "ecs_instance" {
  name   = "${var.environment}-ecs-node-${local.ecs_group_node}-policy"
  role   = aws_iam_role.node_role.name
  policy = data.template_file.node_role_policy_tpl.rendered
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.environment}-ecs-node-${local.ecs_group_node}-profile"
  role = aws_iam_role.node_role.name
}

# iam ecs service role
resource "aws_iam_role" "service_role" {
  name               = "${var.environment}-ecs-service-${local.ecs_group_node}-role"
  description        = "Role to enable to manage ECS service '${local.ecs_group_node}' of ${var.ecs_cluster_name} ECS cluster."
  assume_role_policy = data.aws_iam_policy_document.service_role.json
  tags = {
    Name        = "${var.environment}-ecs-service-${local.ecs_group_node}-role"
    Environment = var.environment
    EcsGroupNode   = local.ecs_group_node
  }
}

resource "aws_iam_role_policy" "service_role_policy" {
  name   = "${var.environment}-ecs-service-${local.ecs_group_node}-role-policy"
  role   = aws_iam_role.service_role.name
  policy = data.template_file.service_role_policy_tpl.rendered
}

## Alarm and scale policy

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
    Environment = var.environment
    EcsGroupNode   = var.ecs_group_node
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
    Environment = var.environment
    EcsGroupNode   = var.ecs_group_node
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
    Environment = var.environment
    EcsGroupNode   = var.ecs_group_node
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
    Environment = var.environment
    EcsGroupNode   = var.ecs_group_node
  }
}

## CloudWatch Logs

resource "aws_cloudwatch_log_group" "ecs_var_log_dmesg" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/dmesg"

  tags = {
    Name        = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/dmesg"
    Environment = var.environment
    EcsGroupNode   = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs_var_log_messages" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/messages"

  tags = {
    Name        = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/messages"
    Environment = var.environment
    EcsGroupNode   = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs_var_log_ecs_ecs_init_log" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/ecs-init.log"

  tags = {
    Name        = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/ecs-init.log"
    Environment = var.environment
    EcsGroupNode   = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs_var_log_ecs_ecs_agent_log" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/ecs-agent.log"

  tags = {
    Name        = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/ecs-agent.log"
    Environment = var.environment
    EcsGroupNode   = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs_var_log_ecs_audit_log" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/audit.log"

  tags = {
    Name        = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/audit.log"
    Environment = var.environment
    EcsGroupNode   = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}
