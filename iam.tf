#----------------------
# AWS IAM role for ECS Node
#----------------------
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

#----------------------
# AWS IAM role for ECS service
#----------------------
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