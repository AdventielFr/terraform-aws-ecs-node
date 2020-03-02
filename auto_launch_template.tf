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
}
