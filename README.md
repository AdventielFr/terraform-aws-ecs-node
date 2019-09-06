
  <table>
    <tr>
      <td style="text-align: center; vertical-align: middle;"><img src="_docs/logo_aws.jpg"/></td>
      <td style="text-align: center; vertical-align: middle;"><img src="_docs/logo_adv.jpg"/></td>
    </tr> 
  <table>



# AWS ECS Cluster Node Terraform module

The purpose of this module is to create an EC2 instances set that will make up the nodes of an ECS cluster.

## I - Infrastructure components 

### I.1 - AWS Auto scaling group
  
This terraform script created **One AWS Auto scaling group** used to ensure high availability of the instance group in the cluster

  Name : **{{environment}}**-ecs-node-**{{ecs_group_node}}**-asg

  Tags : 

  * ECSGroup : **{{ecs_group_node}}**
  * Environment : **{{environment}}**
  * Name : **{{environment}}**-ecs-node-**{{ecs_group_node}}**
  
### I.2 - AWS EC2 Launch configuration

This terraform script created **One AWS Launch configuration** used to deploy an instance of the instance group in the cluster.

  Name : **{{environment}}**-ecs-node-**{{ecs_group_node}}**-lc

### I.3 - AWS EC2 instances

This terraform script created **Many AWS EC2 intances** for the instance group in the cluster.

  Name : **{{environment}}**-ecs-node-**{{ecs_group_node}}**

  Tags : 

  * ECSGroup : **{{ecs_group_node}}**
  * Environment : **{{environment}}**
  * Name : **{{environment}}**-ecs-node-**{{ecs_group_node}}**

### I.4 - AWS Cloudwatch log groups

This terraform script created **Many AWS CloudWatch LogGroup** can be used to monitor the instance group in the cluster

#### I.4.1 - dmesg
  
Name : /aws/ecs/**{{ecs_cluster_name}}**/node/**{{ecs_group_node}}**/var/log/dmesg

Recover the contents of the **/var/log/dmesg** file of instances of the cluster instance group

#### I.4.2 - audit.log

Name : /aws/ecs/**{{ecs_cluster_name}}**/node/**{{ecs_group_node}}**/var/log/audit.log

Recover the contents of the **/var/log/audit.log** file of instances of the cluster instance group

#### I.4.3 - ecs-init

Name : /aws/ecs/**{{ecs_cluster_name}}**node/**{{ecs_group_node}}**/var/log/ecs-init.log

Recover the contents of the **/var/log/ecs-init.log** file of instances of the cluster instance group

#### I.4.4 - ecs-init

Name : /aws/ecs/**{{ecs_cluster_name}}**/node/**{{ecs_group_node}}**/var/log/ecs-restart.log

Recover the contents of the **/var/log/ecs-restart.log** file of instances of the cluster instance group

#### I.4.5 - messages

Name : aws/ecs/**{{ecs_cluster_name}}**/node/**{{ecs_group_node}}**/var/log/message.log

Recover the contents of the **/var/log/messages** file of instances of the cluster instance group


### I.5 - AWS CloudWatch Alarm 

This terraform script created **Many AWS CloudWatch Alarm** for the instance group in the cluster.

#### I.5.1 - CPU alarm scale down

Name : * **{{environment}}**-ecs-**{{ecs_group_node}}**-cpu-alarm-scale-down**

This alarm reduces the number of instances in the instance group when the cpu consumption is greater than a threshold.

#### I.5.2 - CPU alarm scale up

Name : * **{{environment}}**-ecs-**{{ecs_group_node}}**-cpu-alarm-scale-up**

This alarm increases the number of instances in the instance group when the cpu consumption is greater than a threshold.

#### I.5.3 - Memory alarm scale down

Name : **{{environment}}**-ecs-**{{ecs_group_node}}**-memory-alarm-scale-down**

This alarm reduces the number of instances in the instance group when the memory consumption is greater than a threshold.

#### I.5.4 - Memory alarm scale up

Name : **{{environment}}**-ecs-**{{ecs_group_node}}**-memory-alarm-scale-up

This alarm increases the number of instances in the instance group when the memory consumption is greater than a threshold.

### I.6 - AWS S3 shared bucket ( optional )

This terraform script created **One S3 Bucket**. This bucket can be used to exchange data as a file between ECS service.

Name : **{{environment}}**-ecs-shared

### I.7 - AWS IAM Role and Policies

This terraform script created a set of role iam.

### I.7.1 - AWS IAM for EC2 cluster node

This IAM role is applied to differences in the instance group

Name : **{{environment}}**-ecs-node-**{{ecs_group_node}}**-role

### I.7.2 - AWS IAM for ECS service 

This IAM role is applied to differences in the instance group

Name : **{{environment}}**-ecs-service-**{{ecs_group_node}}**-role

## II - Inputs / Outputs

### Inputs

| Name | Description | Type | Default |
|------|-------------|:----:|:-----:|
| alarm\_cpu\_scale\_down\_evaluation\_periods | The number of periods over which data is compared to the specified threshold for Alarm CPU scale down | number | 2 |
| alarm\_cpu\_scale\_down\_threshold | The CPU consumption threshold of the instance group that triggers the reduction of the number of instances in the instance group | number | 10 |
| alarm\_cpu\_scale\_up\_evaluation\_periods | The number of periods over which data is compared to the specified threshold for Alarm CPU scale up | number | 2 |
| alarm\_cpu\_scale\_up\_threshold | The CPU consumption threshold of the instance group that triggers an increase in the number of instances in the instance group | number | 90 |
| alarm\_memory\_scale\_down\_evaluation\_periods | The number of periods over which data is compared to the specified threshold for Alarm memory scale down | number | 2 |
| alarm\_memory\_scale\_down\_threshold | The memory consumption threshold of the instance group that triggers the reduction of the number of instances in the instance group | number | 10 |
| alarm\_memory\_scale\_up\_evaluation\_periods | The number of periods over which data is compared to the specified threshold for Alarm memory scale up | number | 2 |
| alarm\_memory\_scale\_up\_threshold | The memory consumption threshold of the instance group that triggers an increase in the number of instances in the instance group | number | 90 |
| alarm\_policy\_scale\_down\_cool\_down | For scale down, the amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start. | number | 300 |
| alarm\_policy\_scale\_up\_cool\_down | For scale up, the amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start. | number | 300 |
| alarm\_scale\_down\_scaling\_adjustment | For Alarms scale down, the number of instances by which to scale. adjustment\_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity. | number | -1 |
| alarm\_scale\_up\_scaling\_adjustment | For Alarms scale up, the number of instances by which to scale. adjustment\_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity | number | 1 |
| asg\_desired | The desired numbers of instances in the auto scaling group. | number | 1 |
| asg\_health\_period | Time (in seconds) after instance comes into service before checking health. | number | 300 |
| asg\_max | The maximum numbers of instances in the auto scaling group. | number | 1 |
| asg\_min | The minimum numbers of instances in the auto scaling group. | number | 1 |
| aws\_region | The AWS region to deploy | string | n/a |
| bucket\_force\_destroy | The bucket and all objects should be destroyed when using true | bool | false |
| create\_shared\_bucket | Create shared bucket | bool | false |
| ecs\_agent\_loglevel | The level to log at on stdout for esc agent. | string | "info" |
| ecs\_cloudwath\_retention\_in\_days | The Cloudwath retention days. | number | 7 |
| ecs\_cluster\_name | The name of the ECS cluster. | string | n/a |
| ecs\_enable\_task\_iam\_role | Enables IAM roles for tasks for containers with the bridge and default network modes. | bool | false |
| ecs\_enable\_task\_iam\_role\_network\_host | Enables IAM roles for tasks for containers with the host network mode. This variable is only supported. | bool | false |
| ecs\_group\_node | The groupe node | string | "default" |
| ecs\_image\_pull\_behavior | The behavior used to customize the pull image process for your container instances. | string | "default" |
| ecs\_optimized\_amis | The map of region to ecs optimized AMI. By default the latest available will be chosen. | map | {} |
| environment | The logical name of the environment, will be used as prefix and in tags. | string | n/a |
| instance\_security\_groups | The List of security group for ecs cluster node. | list(string) | n/a |
| instance\_type | Default AWS instance type. | string | "t2.small" |
| key\_name | The name of AWS key pair | string | "" |
| subnets | The subnets where the instances will be deployed to. | list(string) | n/a |
| use\_shared\_bucket | Use shared bucket | bool | true |
| user\_data | The override the module embedded user data script. | string | "" |
| vpc\_cidr | The CIDR for the VPC. | string | n/a |
| vpc\_id | The ID of the VPC. | string | n/a |

### Outputs

| Name | Description |
|------|-------------|
| aws\_autoscaling\_group\_arn | The ARN for this AutoScaling Group. |
| aws\_autoscaling\_group\_id | The autoscaling group id. |
| aws\_autoscaling\_group\_name | The name of the autoscale group. |
| aws\_launch\_configuration\_id | The ID of the launch configuration. |
| aws\_launch\_configuration\_name | The name of the launch configuration. |
| role\_node\_arn | The ARN of IAM role ecs instance role |
| role\_service\_arn | The ARN of IAM role ecs service role |

## III - Usage

`````

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-cluster"
  tags = {
    Environment = "eu-west-3"
  }
}


module "ecs_cluster_node" {
  source  = "git::https://github.com/AdventielFr/terraform-aws-ecs-node.git?ref=0.1.0"

  # deployment informations
  aws_region       = "eu-west-3"
  environment      = "stage"

  # cluster node informations
  ecs_cluster_name = "my-cluster"
  ecs_group_node   = "my-group-node"
  instance_type    = "t2.micro"

  # network informations
  vpc_id        = "vpc-09bcb8c4bdc12xxxx"
  vpc_cidr      = "10.0.0.0/16"
  subnets       = [
      "subnet-0a632ea35bfa2xxxx",
      "subnet-0c6f42baa5077xxxx"
  ]
  
  # auto scaling informations
  asg_min       = 2
  asg_max       = 3
  asg_desired   = 2

  # alarn informations
  # scale up <80% CPU used on group instances
  alarm_cpu_scale_up_threshold = 80
  # scale down >10% CPU used on group instances
  alarm_cpu_scale_up_threshold = 10

  # shared bucket informations
  create_shared_bucket                  = true

  # ecs.config informations ( show https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html )
  ecs_image_pull_behavior               = "always"
  ecs_enable_task_iam_role              = true
  ecs_enable_task_iam_role_network_host = true
  ecs_enable_task_iam_role              = true
  ecs_enable_task_iam_role_network_host = true
  ecs_agent_loglevel                    = "infoe

  # security group informations
  instance_security_groups = [
    data.terraform_remote_state.vpc.outputs.security_group_all_from_private,
    data.terraform_remote_state.vpc.outputs.security_group_all_from_public,
    data.terraform_remote_state.vpc.outputs.security_group_http_from_internet
  ]
}

`````
