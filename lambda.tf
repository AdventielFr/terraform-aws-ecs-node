
resource "aws_lambda_function" "auto_update_ecs_cluster_agent" {
  count         = var.auto_update_ecs_agent && length(aws_iam_role.auto_update_ecs_cluster_agent)>0 ? 1 : 0
  function_name = local.auto_update_ecs_cluster_agent_lambda_name
  memory_size   = 128
  description   = "Auto update ECS cluster Agent for ${local.ecs_group_node} group node in ${var.ecs_cluster_name}"
  timeout       = var.function_timeout
  runtime       = "python3.7"
  filename      = "${path.module}/auto-update-ecs-cluster-agent.zip"
  handler       = "lambda_handler.main"
  role          = aws_iam_role.auto_update_ecs_cluster_agent[0].arn

  environment {
    variables = {
      AWS_SNS_RESULT_ARN = aws_sns_topic.auto_update_ecs_cluster_agent[0].arn
      ECS_CLUSTER_NAME   = var.ecs_cluster_name
      ECS_GROUP_NODE     = local.ecs_group_node
    }
  }

  tags = {
    Environment  = var.environment
    EcsCluster   = var.ecs_cluster_name
    EcsGroupNode = var.ecs_group_node
    Lambda       = local.auto_update_ecs_cluster_agent_lambda_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.auto_update_ecs_cluster_agent,
    aws_cloudwatch_log_group.auto_update_ecs_cluster_agent
  ]
}

resource "aws_sns_topic" "auto_update_ecs_cluster_agent" {
  count        = var.auto_update_ecs_agent ? 1 : 0
  name         = "${local.auto_update_ecs_cluster_agent_lambda_name}-result"
  display_name = "Topic for Auto update ESC cluster Agent Lambda result"
  tags = {
    Environment  = var.environment
    EcsCluster   = var.ecs_cluster_name
    EcsGroupNode = var.ecs_group_node
  }
}


resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  count         = var.auto_update_ecs_agent && length(aws_cloudwatch_event_rule.every_x_minutes)>0 && length(aws_cloudwatch_event_rule.every_x_minutes)>0 ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_update_ecs_cluster_agent[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_x_minutes[0].arn
}

resource "aws_cloudwatch_log_group" "auto_update_ecs_cluster_agent" {
  count             = var.auto_update_ecs_agent ? 1 : 0
  name              = "/aws/lambda/${local.auto_update_ecs_cluster_agent_lambda_name}"
  retention_in_days = var.ecs_cloudwath_retention_in_days
}

resource "aws_cloudwatch_event_rule" "every_x_minutes" {
  count               = var.auto_update_ecs_agent ? 1 : 0
  name                = "${local.auto_update_ecs_cluster_agent_lambda_name}-schedule"
  description         = "Research the ECS container instace for which it is necessary to update ECS Agent for ${local.ecs_group_node} Group node in ${var.ecs_cluster_name} (Fires every ${var.scan_alarm_clock} minutes)"
  schedule_expression = "rate(${var.scan_alarm_clock} minutes)"
}

resource "aws_cloudwatch_event_target" "check_every_x_minutes" {
  count     = var.auto_update_ecs_agent && length(aws_cloudwatch_event_rule.every_x_minutes)>0 && length(aws_lambda_function.auto_update_ecs_cluster_agent)>0 ? 1 : 0
  rule      = aws_cloudwatch_event_rule.every_x_minutes[0].name
  target_id = local.auto_update_ecs_cluster_agent_lambda_name
  arn       = aws_lambda_function.auto_update_ecs_cluster_agent[0].arn
}


data "aws_iam_policy_document" "auto_update_ecs_cluster_agent" {
  count = var.auto_update_ecs_agent ? 1 : 0
  statement {
    sid       = "AllowSNSPermissions"
    effect    = "Allow"
    resources = ["test"
    ]

    actions = [
      "sns:Publish"
    ]
  }

  statement {
    sid       = "AllowECS"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeContainerInstances",
      "ecs:ListAttributes",
      "ecs:ListClusters",
      "ecs:ListContainerInstances",
      "ecs:UpdateContainerAgent"
    ]
  }

  statement {
    sid       = "AllowCloudwatck"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

resource "aws_iam_policy" "auto_update_ecs_cluster_agent" {
  count  = var.auto_update_ecs_agent && length(data.aws_iam_policy_document.auto_update_ecs_cluster_agent)>0 ? 1 : 0
  name   = "${local.auto_update_ecs_cluster_agent_lambda_name}-policy"
  policy = data.aws_iam_policy_document.auto_update_ecs_cluster_agent[0].json
}

resource "aws_iam_role" "auto_update_ecs_cluster_agent" {
  count              = var.auto_update_ecs_agent ? 1 : 0
  name               = "${local.auto_update_ecs_cluster_agent_lambda_name}-role"
  description        = "Set of access policies granted to lambda ${local.auto_update_ecs_cluster_agent_lambda_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Environment  = var.environment
    EcsCluster   = var.ecs_cluster_name
    EcsGroupNode = var.ecs_group_node
    Lambda       = local.auto_update_ecs_cluster_agent_lambda_name
  }
}

resource "aws_iam_role_policy_attachment" "auto_update_ecs_cluster_agent" {
  count      = var.auto_update_ecs_agent && length(aws_iam_policy.auto_update_ecs_cluster_agent)>0 && length(aws_iam_role.auto_update_ecs_cluster_agent)>0 ? 1 : 0
  policy_arn = aws_iam_policy.auto_update_ecs_cluster_agent[0].arn
  role       = aws_iam_role.auto_update_ecs_cluster_agent[0].name
}
