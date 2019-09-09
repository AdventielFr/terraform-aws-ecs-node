variable "aws_region" {
  description = "The AWS region to deploy"
  type        = string
}

variable "bucket_force_destroy" {
  type        = bool
  default     = false
  description = "The bucket and all objects should be destroyed when using true"
}

variable "create_shared_bucket" {
  type        = bool
  default     = false
  description = "Create shared S3 bucket"
}

variable "use_shared_bucket" {
  type        = bool
  default     = true
  description = "Use shared S3 bucket"
}

variable "key_name" {
  description = "The name of AWS key pair"
  type        = string
  default     = ""
}

variable "instance_type" {
  default     = "t2.small"
  description = "Default AWS instance type."
  type        = string
}

variable "asg_min" {
  description = "The minimum numbers of instances in the auto scaling group."
  default     = 1
  type        = number
}

variable "asg_max" {
  description = "The maximum numbers of instances in the auto scaling group."
  default     = 1
  type        = number
}

variable "asg_health_period" {
  description = "Time (in seconds) after instance comes into service before checking health."
  default     = 300
  type        = number
}

variable "asg_desired" {
  description = "The desired numbers of instances in the auto scaling group."
  default     = 1
  type        = number
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR for the VPC."
  type        = string
}

variable "environment" {
  description = "The logical name of the environment, will be used as prefix and in tags."
  type        = string
}

variable "subnets" {
  description = "The subnets where the instances will be deployed to."
  type        = list(string)
}

variable "ecs_optimized_amis" {
  description = "The map of region to ecs optimized AMI. By default the latest available will be chosen."
  type        = map
  default     = {}
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  type        = string
}

variable "ecs_group_node" {
  description = "The instance group node (show tag ECSGroup ). Use for placement strategy."
  type        = string
  default     = "default"
}

variable "user_data" {
  description = "The override the module embedded user data script."
  type        = string
  default     = ""
}

variable "instance_security_groups" {
  description = "The List of security group for ecs cluster node."
  type        = list(string)
}

variable "ecs_cloudwath_retention_in_days" {
  description = "The Cloudwath retention days for all Cloudwath LogGroup created."
  default     = 7
  type        = number
}

variable "ecs_image_pull_behavior" {
  description = "The behavior used to customize the pull image process for your container instances."
  default     = "default"
  type        = string  
}

variable "ecs_enable_task_iam_role" {
  description = "Enables IAM roles for tasks for containers with the bridge and default network modes."
  default     = false
  type        = bool
}

variable "ecs_enable_task_iam_role_network_host" {
  description = "Enables IAM roles for tasks for containers with the host network mode. This variable is only supported."
  default     = false
  type        = bool
}

variable "ecs_agent_loglevel" {
  description= "The level to log at on stdout for esc agent."
  default     = "info"
  type        = string  
}

variable "alarm_cpu_scale_up_threshold" {
  description = "The CPU consumption threshold of the instance group that triggers an increase in the number of instances in the instance group"
  type        = number
  default     = 90
}

variable "alarm_cpu_scale_down_threshold" {
  description = "The CPU consumption threshold of the instance group that triggers the reduction of the number of instances in the instance group"
  type        = number
  default     = 10
}

variable "alarm_memory_scale_up_threshold" {
  description = "The memory consumption threshold of the instance group that triggers an increase in the number of instances in the instance group"
  type        = number
  default     = 90
}

variable "alarm_memory_scale_down_threshold" {
  description = "The memory consumption threshold of the instance group that triggers the reduction of the number of instances in the instance group"
  type        = number
  default     = 10
}

variable "alarm_cpu_scale_up_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold for Alarm CPU scale up"
  default     = 2
  type        = number
}

variable "alarm_cpu_scale_down_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold for Alarm CPU scale down"
  default     = 2
  type        = number
}

variable "alarm_memory_scale_up_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold for Alarm memory scale up"
  default     = 2
  type        = number
}

variable "alarm_memory_scale_down_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold for Alarm memory scale down"
  default     = 2
  type        = number
}

variable "alarm_scale_up_scaling_adjustment"{
  description = "For Alarms scale up, the number of instances by which to scale. adjustment_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity"
  default     = 1
  type        = number
}

variable "alarm_scale_down_scaling_adjustment"{
  description = "For Alarms scale down, the number of instances by which to scale. adjustment_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity."
  default     = -1
  type        = number
}

variable "alarm_policy_scale_up_cool_down" {
  description = "For scale up, the amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
  default     = 300
  type        = number
}

variable "alarm_policy_scale_down_cool_down" {
  description = "For scale down, the amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
  default     = 300
  type        = number
}