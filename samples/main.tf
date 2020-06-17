provider "aws" {
  region = local.aws_region
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.environment
}

locals {
  aws_region     = "eu-west-1"
  all_cidr       = "0.0.0.0/0"
  cidr           = "10.0.0.0/16"
  azs            = ["eu-west-1a"]
  public_subnets = ["10.0.0.0/22"]
  environment    = "my-sample"
}

#----------------------------
# Module VPC
#----------------------------
module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "2.24.0"
  name                 = local.environment
  cidr                 = local.cidr
  public_subnets       = local.public_subnets
  azs                  = local.azs
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true

  public_subnet_tags = {
    Domain      = "public"
    Environment = local.environment
  }

  public_route_table_tags = {
    Domain      = "public"
    Environment = local.environment
  }

  vpc_tags = {
    Environment = local.environment
  }

  tags = {
    Environment = local.environment
  }

  igw_tags = {
    Environment = local.environment
  }

  nat_eip_tags = {
    Environment = local.environment
  }

  nat_gateway_tags = {
    Environment = local.environment
  }
}

resource "aws_security_group" "allow_all_from_internet" {
  name        = "${local.environment}-all-from-internet-sg"
  description = "Enable all ports inbound traffic from internet subnets"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [
      local.all_cidr
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [local.all_cidr]
  }

  tags = {
    Name        = "${local.environment}-all-from-internet-sg"
    Environment = local.environment
    Domain      = "public"
  }
}

data "local_file" "sample_pub" {
  filename = "sample.pub"
}

resource "aws_key_pair" "ecs_instance_key" {
  key_name   = "${local.environment}-ecs-key"
  public_key = data.local_file.sample_pub.content
}

module "ecs_cluster" {

  source = "../"

  # deployment informations
  aws_region  = local.aws_region
  environment = local.environment
  key_name       = aws_key_pair.ecs_instance_key.key_name

  # cluster node informations
  ecs_cluster_name = aws_ecs_cluster.ecs_cluster.name
  ecs_group_node   = "my-group-node"
  instance_type    = "t2.micro"

  # network informations
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr_block
  subnets  = module.vpc.public_subnets

  # auto scaling informations
  asg_min     = 1
  asg_max     = 2
  asg_desired = 1

  # alarn informations
  # scale up <80% CPU used on group instances
  alarm_cpu_scale_up_threshold = 80
  # scale down >10% CPU used on group instances
  alarm_cpu_scale_down_threshold = 10

  # ecs.config informations ( show https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html )
  ecs_image_pull_behavior               = "always"
  ecs_enable_task_iam_role              = true
  ecs_enable_task_iam_role_network_host = true
  ecs_agent_loglevel                    = "info"

  instance_security_groups = [
    aws_security_group.allow_all_from_internet.id
  ]

}