resource "aws_cloudwatch_log_group" "ecs_var_log_dmesg" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/dmesg"

  tags = {
    Name         = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/dmesg"
    Environment  = var.environment
    EcsGroupNode = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs_var_log_messages" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/messages"

  tags = {
    Name         = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/messages"
    Environment  = var.environment
    EcsGroupNode = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs_var_log_ecs_ecs_init_log" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/ecs-init.log"

  tags = {
    Name         = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/ecs-init.log"
    Environment  = var.environment
    EcsGroupNode = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs_var_log_ecs_ecs_agent_log" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/ecs-agent.log"

  tags = {
    Name         = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/ecs-agent.log"
    Environment  = var.environment
    EcsGroupNode = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs_var_log_ecs_audit_log" {
  name = "/aws/ecs/${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/audit.log"

  tags = {
    Name         = "${var.ecs_cluster_name}/node/${local.ecs_group_node}/var/log/ecs/audit.log"
    Environment  = var.environment
    EcsGroupNode = var.ecs_group_node
  }

  retention_in_days = var.ecs_cloudwath_retention_in_days
}
