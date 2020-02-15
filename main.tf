#----------------------
# locals
#----------------------
locals {
  aws_ami_userdefined                       = lookup(var.ecs_optimized_amis, var.aws_region, "")
  aws_ami                                   = local.aws_ami_userdefined == "" ? data.aws_ami.aws_optimized_ecs.id : local.aws_ami_userdefined
  user_data_aws                             = var.user_data == "" ? data.template_file.user_data_tpl.rendered : var.user_data
  ecs_group_node                            = var.ecs_group_node == "" ? "default" : var.ecs_group_node
  auto_update_ecs_cluster_agent_lambda_name = "${var.ecs_cluster_name}-${ecs_group_node}-update-agent"
  ecs_http_proxy                            = var.ecs_http_proxy != "" ? "echo HTTP_PROXY=${var.ecs_http_proxy} >> /etc/ecs/ecs.config" : ""
  ecs_no_proxy                              = var.ecs_no_proxy != "" ? "echo NO_PROXY=${var.ecs_no_proxy} >> /etc/ecs/ecs.config" : ""
  cloudwatch_agent_config_content           = var.cloudwatch_agent_metrics_config == "minimal" ? data.template_file.cloudwatch_agent_configuration_minimal_tpl.rendered : (var.cloudwatch_agent_metrics_config == "custom" ? var.cloudwatch_agent_metrics_custom_config_content : (var.cloudwatch_agent_metrics_config == "standard" ? data.template_file.cloudwatch_agent_configuration_standard_tpl.rendered : (var.cloudwatch_agent_metrics_config == "advanced" ? data.template_file.cloudwatch_agent_configuration_advanced_tpl.rendered : "")))
  ebs_no_device                             = var.ebs_volume_size <= 0
  user_data_option_ebs                      = local.ebs_no_device ? "" : data.template_file.user_data_ebs_option_tpl.rendered
  user_data_option_efs                      = var.efs_volume == "" ? "" : data.template_file.user_data_efs_option_tpl.rendered
  user_data_option_cloudwatch_agent         = local.cloudwatch_agent_config_content == "" ? "" : data.template_file.user_data_cloudwath_agent_option_tpl.rendered
  enabled_cloudwatch_event_autoscaling      = var.cloudwatch_event_autoscaling_sns_arn != ""
  ebs_device                                = "/dev/xvdk"
  cloudwatch_agent_metrics_disk_resources   = local.ebs_no_device ? var.cloudwatch_agent_metrics_disk_resources : concat(var.cloudwatch_agent_metrics_disk_resources, [var.ecs_datadir])
}


#----------------------
# resources
#----------------------

# launch template
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

}

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
    id      = local.ebs_no_device ? aws_launch_template.without_ebs[0].id : aws_launch_template.with_ebs[0].id
    version = "$Latest"
  }
}

# iam ec2 cluster node role
resource "aws_iam_role" "node_role" {
  name               = "${var.environment}-ecs-node-${local.ecs_group_node}-role"
  description        = "Role to enable to manage EC2 node '${local.ecs_group_node}' of ${var.ecs_cluster_name} ECS cluster."
  assume_role_policy = data.aws_iam_policy_document.node_role.json

  tags = {
    Name         = "${var.environment}-ecs-node-${local.ecs_group_node}-role"
    Environment  = var.environment
    EcsGroupNode = local.ecs_group_node
  }
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_attachment_1" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_attachment_2" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_attachment_3" {
  count      = var.cloudwatch_agent_metrics_config != "" ? 1 : 0
  role       = aws_iam_role.node_role.name
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
    Name         = "${var.environment}-ecs-service-${local.ecs_group_node}-role"
    Environment  = var.environment
    EcsGroupNode = local.ecs_group_node
  }
}

resource "aws_iam_role_policy" "service_role_policy" {
  name   = "${var.environment}-ecs-service-${local.ecs_group_node}-role-policy"
  role   = aws_iam_role.service_role.name
  policy = data.template_file.service_role_policy_tpl.rendered
}
