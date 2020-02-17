
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
    efs_volume      = var.efs_volume
  }
}

data "template_file" "user_data_ebs_option_tpl" {
  template = "${file("${path.module}/templates/user-data-opt-ebs.tpl")}"

  vars = {
    ecs_datadir = var.ecs_datadir
    ebs_device  = local.ebs_device
  }
}

data "template_file" "user_data_cloudwath_agent_option_tpl" {
  template = "${file("${path.module}/templates/user-data-opt-cloudwatch-agent.tpl")}"

  vars = {
    region                          = var.aws_region
    cloudwatch_agent_config_content = local.cloudwatch_agent_config_content
  }
}

data "template_file" "user_data_auto_restart_ecs_agent_option_tpl" {
  template = "${file("${path.module}/templates/user-data-opt-auto-restart-ecs-agent.tpl")}"
}

data "template_file" "cloudwatch_agent_configuration_minimal_tpl" {
  template = "${file("${path.module}/templates/cloudwatch_agent_configuration_minimal.tpl")}"

  vars = {
    metrics_collection_interval = var.cloudwatch_agent_metrics_collection_interval
    disk_resources              = jsonencode(local.cloudwatch_agent_metrics_disk_resources)
    cpu_resources               = var.cloudwatch_agent_metrics_cpu_resources
  }

}

data "template_file" "cloudwatch_agent_configuration_standard_tpl" {
  template = "${file("${path.module}/templates/cloudwatch_agent_configuration_standard.tpl")}"

  vars = {
    metrics_collection_interval = var.cloudwatch_agent_metrics_collection_interval
    disk_resources              = jsonencode(local.cloudwatch_agent_metrics_disk_resources)
    cpu_resources               = var.cloudwatch_agent_metrics_cpu_resources
  }

}

data "template_file" "cloudwatch_event_rules_autoscaling" {
  template = "${file("${path.module}/templates/cloudwatch_event_rules_autoscaling.tpl")}"

  vars = {
    name_autoscaling_group = aws_autoscaling_group.this.name
  }

}

data "template_file" "cloudwatch_agent_configuration_advanced_tpl" {
  template = "${file("${path.module}/templates/cloudwatch_agent_configuration_advanced.tpl")}"

  vars = {
    metrics_collection_interval = var.cloudwatch_agent_metrics_collection_interval
    disk_resources              = jsonencode(local.cloudwatch_agent_metrics_disk_resources)
    cpu_resources               = var.cloudwatch_agent_metrics_cpu_resources
  }
}

data "template_file" "user_data_tpl" {
  template = "${file("${path.module}/templates/user-data.tpl")}"

  vars = {
    environment                             = var.environment
    ecs_cluster_name                        = var.ecs_cluster_name
    ecs_group_node                          = local.ecs_group_node
    aws_region                              = var.aws_region
    ecs_agent_loglevel                      = var.ecs_agent_loglevel
    ecs_image_pull_behavior                 = var.ecs_image_pull_behavior
    ecs_group_node                          = local.ecs_group_node
    ecs_enable_task_iam_role                = var.ecs_enable_task_iam_role
    ecs_enable_task_iam_role_network_host   = var.ecs_enable_task_iam_role_network_host
    ecs_disable_image_cleanup               = var.ecs_disable_image_cleanup
    ecs_image_cleanup_interval              = var.ecs_image_cleanup_interval
    ecs_image_minimum_cleanup_age           = var.ecs_image_minimum_cleanup_age
    ecs_num_images_delete_per_cycle         = var.ecs_num_images_delete_per_cycle
    ecs_container_stop_timeout              = var.ecs_container_stop_timeout
    ecs_container_start_timeout             = var.ecs_container_start_timeout
    ecs_enable_spot_instance_draining       = var.ecs_enable_spot_instance_draining
    ecs_disable_privileged                  = var.ecs_disable_privileged
    ecs_selinux_capable                     = var.ecs_selinux_capable
    ecs_apparmor_capable                    = var.ecs_selinux_capable
    ecs_engine_task_cleanup_wait_duration   = var.ecs_engine_task_cleanup_wait_duration
    ecs_enable_task_eni                     = var.ecs_enable_task_eni
    ecs_datadir                             = var.ecs_datadir
    ecs_http_proxy                          = local.ecs_http_proxy
    ecs_no_proxy                            = local.ecs_no_proxy
    ecs_cni_plugins_path                    = var.ecs_cni_plugins_path
    ecs_disable_docker_health_check         = var.ecs_disable_docker_health_check
    cron_definition_restart_ecs_demon       = var.cron_definition_restart_ecs_demon
    user_data_option_efs                    = local.user_data_option_efs
    user_data_option_cloudwatch_agent       = local.user_data_option_cloudwatch_agent
    user_data_option_ebs                    = local.user_data_option_ebs
    user_data_option_auto_restart_ecs_agent = local.user_data_option_auto_restart_ecs_agent
  }
}

data "template_file" "node_role_policy_tpl" {
  template = "${file("${path.module}/templates/node-role-policy.tpl")}"
}

data "template_file" "service_role_policy_tpl" {
  template = "${file("${path.module}/templates/service-role-policy.tpl")}"
}
