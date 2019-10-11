<p align="center">
  <table>
    <tr>
      <td style="text-align: center; vertical-align: middle;"><img src="_docs/logo_aws.jpg"/></td>
      <td style="text-align: center; vertical-align: middle;"><img src="_docs/logo_adv.jpg"/></td>
    </tr> 
  <table>
</p>

# AWS ECS Cluster Node Terraform module

The purpose of this module is to create an EC2 instances set that will make up the nodes of an ECS cluster.

## Infrastructure components

### AWS Auto scaling group
  
This terraform script created **One AWS Auto scaling group** used to ensure high availability of the instance group in the cluster

Name : **{{environment}}**-ecs-node-**{{ecs_group_node}}**-asg

Tags :

* ECSGroup : **{{ecs_group_node}}**

* Environment : **{{environment}}**

* Name : **{{environment}}**-ecs-node-**{{ecs_group_node}}**
  
### AWS EC2 Launch configuration

This terraform script created **One AWS Launch configuration** used to deploy an instance of the instance group in the cluster.

  Name : **{{environment}}**-ecs-node-**{{ecs_group_node}}**-lc

### AWS EC2 instances

This terraform script created **Many AWS EC2 intances** for the instance group in the cluster.

  Name : **{{environment}}**-ecs-node-**{{ecs_group_node}}**

  Tags : 

  * ECSGroup : **{{ecs_group_node}}**
  * Environment : **{{environment}}**
  * Name : **{{environment}}**-ecs-node-**{{ecs_group_node}}**

### AWS Cloudwatch log groups

This terraform script created **Many AWS CloudWatch LogGroup** can be used to monitor the instance group in the cluster

#### dmesg
  
Name : /aws/ecs/**{{ecs_cluster_name}}**/node/**{{ecs_group_node}}**/var/log/dmesg

Recover the contents of the **/var/log/dmesg** file of instances of the cluster instance group

#### audit.log

Name : /aws/ecs/**{{ecs_cluster_name}}**/node/**{{ecs_group_node}}**/var/log/audit.log

Recover the contents of the **/var/log/audit.log** file of instances of the cluster instance group

#### ecs-init

Name : /aws/ecs/**{{ecs_cluster_name}}**node/**{{ecs_group_node}}**/var/log/ecs-init.log

Recover the contents of the **/var/log/ecs-init.log** file of instances of the cluster instance group

#### ecs-restart

Name : /aws/ecs/**{{ecs_cluster_name}}**/node/**{{ecs_group_node}}**/var/log/ecs-restart.log

Recover the contents of the **/var/log/ecs-restart.log** file of instances of the cluster instance group

#### messages

Name : aws/ecs/**{{ecs_cluster_name}}**/node/**{{ecs_group_node}}**/var/log/message.log

Recover the contents of the **/var/log/messages** file of instances of the cluster instance group

### AWS CloudWatch Alarm 

This terraform script created **Many AWS CloudWatch Alarm** for the instance group in the cluster.

#### CPU alarm scale down

Name : * **{{environment}}**-ecs-**{{ecs_group_node}}**-cpu-alarm-scale-down

This alarm reduces the number of instances in the instance group when the cpu consumption is greater than a threshold.

#### CPU alarm scale up

Name : * **{{environment}}**-ecs-**{{ecs_group_node}}**-cpu-alarm-scale-up

This alarm increases the number of instances in the instance group when the cpu consumption is greater than a threshold.

#### Memory alarm scale down

Name : **{{environment}}**-ecs-**{{ecs_group_node}}**-memory-alarm-scale-down

This alarm reduces the number of instances in the instance group when the memory consumption is greater than a threshold.

#### Memory alarm scale up

Name : **{{environment}}**-ecs-**{{ecs_group_node}}**-memory-alarm-scale-up

This alarm increases the number of instances in the instance group when the memory consumption is greater than a threshold.

### AWS S3 shared bucket ( optional )

This terraform script created **One S3 Bucket**. This bucket can be used to exchange data as a file between ECS service.

Name : **{{environment}}**-ecs-shared

### AWS IAM Role and Policies

This terraform script created a set of role iam.

#### AWS IAM for EC2 cluster node

This IAM role is applied to differences in the instance group

Name : **{{environment}}**-ecs-node-**{{ecs_group_node}}**-role

#### AWS IAM for ECS service 

This IAM role is applied to differences in the instance group

Name : **{{environment}}**-ecs-service-**{{ecs_group_node}}**-role

## Inputs / Outputs

### Inputs

| Name | Description | Type | Default |
|------|-------------|:----:|:-----:|
| alarm\_cpu\_scale\_down\_evaluation\_periods | The number of periods over which data is compared to the specified threshold for Alarm CPU scale down | number | 2 |
| alarm\_cpu\_scale\_down\_period | The CPU period of the instance group that triggers an increase in the number of instances in the instance group | number | 180 |
| alarm\_cpu\_scale\_down\_threshold | The CPU consumption threshold of the instance group that triggers the reduction of the number of instances in the instance group | number | 10 |
| alarm\_cpu\_scale\_up\_evaluation\_periods | The number of periods over which data is compared to the specified threshold for Alarm CPU scale up | number | 2 |
| alarm\_cpu\_scale\_up\_period | The CPU period of the instance group that triggers an increase in the number of instances in the instance group | number | 180 |
| alarm\_cpu\_scale\_up\_threshold | The CPU consumption threshold of the instance group that triggers an increase in the number of instances in the instance group | number | 90 |
| alarm\_memory\_scale\_down\_evaluation\_periods | The number of periods over which data is compared to the specified threshold for Alarm memory scale down | number | 2 |
| alarm\_memory\_scale\_down\_period | The memory period of the instance group that triggers an increase in the number of instances in the instance group | number | 180 |
| alarm\_memory\_scale\_down\_threshold | The memory consumption threshold of the instance group that triggers the reduction of the number of instances in the instance group | number | 10 |
| alarm\_memory\_scale\_up\_evaluation\_periods | The number of periods over which data is compared to the specified threshold for Alarm memory scale up | number | 2 |
| alarm\_memory\_scale\_up\_period | The memory period of the instance group that triggers an increase in the number of instances in the instance group | number | 180 |
| alarm\_memory\_scale\_up\_threshold | The memory consumption threshold of the instance group that triggers an increase in the number of instances in the instance group | number | 90 |
| alarm\_policy\_scale\_down\_cool\_down | For scale down, the amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start. | number | 300 |
| alarm\_policy\_scale\_up\_cool\_down | For scale up, the amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start. | number | 300 |
| alarm\_scale\_down\_scaling\_adjustment | For Alarms scale down, the number of instances by which to scale. adjustment\_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity. | number | -1 |
| alarm\_scale\_up\_scaling\_adjustment | For Alarms scale up, the number of instances by which to scale. adjustment\_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity | number | 1 |
| asg\_desired | The desired numbers of instances in the auto scaling group. | number | 1 |
| asg\_health\_period | Time (in seconds) after instance comes into service before checking health. | number | 180 |
| asg\_max | The maximum numbers of instances in the auto scaling group. | number | 1 |
| asg\_min | The minimum numbers of instances in the auto scaling group. | number | 1 |
| aws\_region | The AWS region to deploy | string | n/a |
| cloudwatch\_agent\_config\_content | The content of cloudwatch agent configuration. if empty the cloudwatch agent if not installed. | string | "" |
| ecs\_agent\_loglevel | The level to log at on stdout for esc agent. | string | "info" |
| ecs\_apparmor\_capable | Whether AppArmor is available on the container instance. | bool | false |
| ecs\_cloudwath\_retention\_in\_days | The Cloudwath retention days for all Cloudwath LogGroup created. | number | 7 |
| ecs\_cluster\_name | The name of the ECS cluster. | string | n/a |
| ecs\_cni\_plugins\_path | The path where the cni binary file is located. | string | "/amazon-ecs-cni-plugins" |
| ecs\_container\_start\_timeout | Time duration to wait before giving up on starting a container. | string | "3m" |
| ecs\_container\_stop\_timeout | Time duration to wait from when a task is stopped before its containers are forcefully killed if they do not exit normally on their own. | string | "30s" |
| ecs\_disable\_docker\_health\_check | Whether to disable the Docker container health check for the ECS Agent. | bool | false |
| ecs\_disable\_image\_cleanup | Whether to disable automated image cleanup for the Amazon ECS agent. For more information. | bool | false |
| ecs\_disable\_privileged | Whether launching privileged containers is disabled on the container instance. If this value is set to true, privileged containers are not permitted. | bool | false |
| ecs\_enable\_container\_metadata | When true, the agent creates a file describing the container's metadata. The file can be located and consumed by using the container environment variable $ECS\_CONTAINER\_METADATA\_FILE. | bool | true |
| ecs\_enable\_spot\_instance\_draining | Whether to enable Spot Instance draining for the container instance. | bool | false |
| ecs\_enable\_task\_eni | Whether to enable task networking for tasks to be launched with their own network interface. | bool | false |
| ecs\_enable\_task\_iam\_role | Enables IAM roles for tasks for containers with the bridge and default network modes. | bool | false |
| ecs\_enable\_task\_iam\_role\_network\_host | Enables IAM roles for tasks for containers with the host network mode. This variable is only supported. | bool | false |
| ecs\_engine\_task\_cleanup\_wait\_duration | Time duration to wait from when a task is stopped until the Docker container is removed. As this removes the Docker container data, be aware that if this value is set too low, you may not be able to inspect your stopped containers or view the logs before they are removed. The minimum duration is 1m; any value shorter than 1 minute is ignored. | string | "3h" |
| ecs\_group\_node | The instance group node (show tag EcsGroupNode). Use for placement strategy. | string | "default" |
| ecs\_http\_proxy | The hostname (or IP address) and port number of an HTTP proxy to use for the ECS agent to connect to the internet (for example, if your container instances do not have external network access through an Amazon VPC internet gateway or NAT gateway or instance). If this variable is set, you must also set the NO\_PROXY variable to filter EC2 instance metadata and Docker daemon traffic from the proxy. | string | "" |
| ecs\_image\_cleanup\_interval | The time interval between automated image cleanup cycles. If set to less than 10 minutes, the value is ignored. | string | "30m" |
| ecs\_image\_minimum\_cleanup\_age | The minimum time interval between when an image is pulled and when it can be considered for automated image cleanup. | string | "1h" |
| ecs\_image\_pull\_behavior | The behavior used to customize the pull image process for your container instances. | string | "default" |
| ecs\_no\_proxy | The HTTP traffic that should not be forwarded to the specified HTTP\_PROXY. You must specify 169.254.169.254,/var/run/docker.sock to filter EC2 instance metadata and Docker daemon traffic from the proxy. | string | "" |
| ecs\_num\_images\_delete\_per\_cycle | The maximum number of images to delete in a single automated image cleanup cycle. If set to less than 1, the value is ignored. | number | 5 |
| ecs\_optimized\_amis | The map of region to ecs optimized AMI. By default the latest available will be chosen. | map | {} |
| ecs\_selinux\_capable | Whether SELinux is available on the container instance. | bool | false |
| efs\_mount\_point | The EFS volume mount point for EC2 instances. | "string" | "/mnt/efs" |
| efs\_volume | The EFS volume to attach to ec2 instances. ( ex : fs-05a856xx) | string | "" |
| environment | The logical name of the environment, will be used as prefix and in tags. | string | n/a |
| instance\_security\_groups | The List of security group for ecs cluster node. | list(string) | n/a |
| instance\_type | Default AWS instance type. | string | "t2.small" |
| key\_name | The name of AWS key pair | string | "" |
| subnets | The subnets where the instances will be deployed to. | list(string) | n/a |
| time\_between\_two\_restart\_ecs\_demon | Number of minutes between restarting the ecs daemon for sts management. | number | 360 |
| user\_data | The override the module embedded user data script. | string | "" |
| vpc\_cidr | The CIDR for the VPC. | string | n/a |
| vpc\_id | The ID of the VPC. | string | n/a |

### Outputs

| Name | Description |
|------|-------------|
| aws\_autoscaling\_group\_arn | The ARN for this AutoScaling Group. |
| aws\_autoscaling\_group\_id | The autoscaling group id. |
| aws\_autoscaling\_group\_name | The name of the autoscale group. |
| aws\_launch\_template\_id | The ID of the launch template. |
| aws\_launch\_template\_name | The name of the launch template. |
| role\_node\_arn | The ARN of IAM role ecs instance role |
| role\_service\_arn | The ARN of IAM role ecs service role |

## Usage

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
