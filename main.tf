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

data "template_file" "user_data_tpl" {
  template = "${file("${path.module}/user-data.tpl")}"

  vars = {
    ecs_cluster_name = var.ecs_cluster_name
    ecs_group_node = local.ecs_group_node
    aws_region = var.aws_region
    ecs_agent_loglevel = var.ecs_agent_loglevel
    ecs_image_pull_behavior = var.ecs_image_pull_behavior
    ecs_group_node = local.ecs_group_node
    ecs_enable_task_iam_role = var.ecs_enable_task_iam_role
    ecs_enable_task_iam_role_network_host = var.ecs_enable_task_iam_role_network_host
  }
}

data "template_file" "node_role_policy_tpl" {
  template = "${file("${path.module}/node-role-policy.tpl")}"

  vars = {
    bucket_restriction = local.shared_bucker_id
  }
}

data "template_file" "service_role_policy_tpl" {
  template = "${file("${path.module}/service-role-policy.tpl")}"
}

#----------------------
# locals
#----------------------
locals {
  aws_ami_userdefined = "${lookup(var.ecs_optimized_amis, var.aws_region, "")}"
  aws_ami             = "${local.aws_ami_userdefined == "" ? data.aws_ami.aws_optimized_ecs.id : local.aws_ami_userdefined}"
  use_bucket          = var.create_shared_bucket ? true : var.use_shared_bucket
  user_data_aws       = "${var.user_data == "" ? data.template_file.user_data_tpl.rendered : var.user_data}"
  shared_bucker_id    = "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-${var.environment}-ecs-shared"
  ecs_group_node      = var.ecs_group_node == "" ? "default": var.ecs_group_node
}

#----------------------
# resources
#----------------------

# launch configuration 
resource "aws_launch_configuration" "this" {
  name                 = "${var.environment}-ecs-node-${local.ecs_group_node}-lc"
  security_groups      = var.instance_security_groups
  key_name             = var.key_name
  image_id             = local.aws_ami
  user_data            = local.user_data_aws
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.this.name
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
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
  launch_configuration      = aws_launch_configuration.this.name

  tag {
    key                 = "Name"
    value               = "${var.environment}-ecs-node-${local.ecs_group_node}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  } 

  tag {
    key                 = "ECSGroup"
    value               = local.ecs_group_node
    propagate_at_launch = true
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
    ECSGroup    = local.ecs_group_node
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

resource "aws_iam_role_policy" "ecs_instance" {
  count = local.use_bucket ? 1 : 0
  name   = "${var.environment}-ecs-node-${local.ecs_group_node}-policy"
  role   = aws_iam_role.node_role.name
  policy = data.template_file.node_role_policy_tpl.rendered
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.environment}-ecs-node-${local.ecs_group_node}-profile-a"
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
    ECSGroup    = local.ecs_group_node
  }
}

resource "aws_iam_role_policy" "service_role_policy" {
  name   = "${var.environment}-ecs-service-${local.ecs_group_node}-role-policy"
  role   = aws_iam_role.service_role.name
  policy = data.template_file.service_role_policy_tpl.rendered
}

# s3 bucket share
resource "aws_s3_bucket" "ecs_s3_bucket" {
  count         = var.create_shared_bucket ? 1 : 0
  bucket        = "${data.aws_caller_identity.current.account_id}-${var.environment}-ecs-shared"
  force_destroy =  var.bucket_force_destroy

  tags = {
    Name        = "${data.aws_caller_identity.current.account_id}-${var.environment}-ecs-shared"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_object" "ecs_s3_bucket_in" {
  count   = var.create_shared_bucket ? 1 : 0
  bucket  = element(aws_s3_bucket.ecs_s3_bucket.*.id,0)
  acl     = "private"
  key     = "/in/README.txt"
  content = "Contains the files to process"
}

resource "aws_s3_bucket_object" "ecs_s3_bucket_out" {
  count   = var.create_shared_bucket ? 1 : 0
  bucket  = element(aws_s3_bucket.ecs_s3_bucket.*.id,0)
  acl     = "private"
  key     = "/out/README.txt"
  content = "Contains the treatment results files"
}

resource "aws_s3_bucket_object" "ecs_s3_bucket_tmp" {
  count   = var.create_shared_bucket ? 1 : 0
  bucket  = element(aws_s3_bucket.ecs_s3_bucket.*.id,0)
  acl     = "private"
  key     = "/tmp/README.txt"
  content = "Contains the temporary files"
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
  comparison_operator = "GreaterThanOrEqualToThreshold" 
  evaluation_periods  = var.alarm_cpu_scale_up_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
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
    ECSGroup    = var.ecs_group_node
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm_scale_up" {
  alarm_name          = "${var.environment}-ecs-${local.ecs_group_node}-memory-alarm-scale-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_memory_scale_up_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/EC2"
  period              = 300
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
    ECSGroup    = var.ecs_group_node
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

resource "aws_cloudwatch_metric_alarm" "memory_alarm_scaledown" {
  alarm_name          = "${var.environment}-ecs-${local.ecs_group_node}-memory-alarm-scale-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_memory_scale_down_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/EC2"
  period              = 300
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
    ECSGroup    = var.ecs_group_node
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_scaledown" {
  alarm_name          = "${var.environment}-ecs-${local.ecs_group_node}-cpu-alarm-scale-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_cpu_scale_down_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
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
    ECSGroup    = var.ecs_group_node
  }
}

## CloudWatch Logs

resource "aws_cloudwatch_log_group" "ecs_var_log_dmesg" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/dmesg"

  tags = {
    Name        = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/dmesg"
    Environment = var.environment
    ECSGroup    = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs_var_log_messages" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/messages"

  tags = {
    Name        = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/messages"
    Environment = var.environment
    ECSGroup    = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs_var_log_ecs_ecs_init_log" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/ecs-init.log"

  tags = {
    Name        = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/ecs-init.log"
    Environment = var.environment
    ECSGroup    = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs_var_log_ecs_ecs_agent_log" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/ecs-agent.log"

  tags = {
    Name        = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/ecs-agent.log"
    Environment = var.environment
    ECSGroup    = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs_var_log_ecs_audit_log" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/audit.log"

  tags = {
    Name        = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/audit.log"
    Environment = var.environment
    ECSGroup    = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}
