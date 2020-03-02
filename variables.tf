variable "aws_region" {
  description = "The AWS region to deploy"
  type        = string
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
  default     = 180
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
  description = "The instance group node (show tag EcsGroupNode). Use for placement strategy."
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
  default     = []
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

variable "ecs_disable_image_cleanup" {
  description = "Whether to disable automated image cleanup for the Amazon ECS agent. For more information."
  default     = false
  type        = bool
}

variable "ecs_image_cleanup_interval" {
  description = "The time interval between automated image cleanup cycles. If set to less than 10 minutes, the value is ignored."
  default     = "30m"
  type        = string
}

variable "ecs_image_minimum_cleanup_age" {
  description = "The minimum time interval between when an image is pulled and when it can be considered for automated image cleanup."
  default     = "1h"
  type        = string
}

variable "ecs_num_images_delete_per_cycle" {
  description = "The maximum number of images to delete in a single automated image cleanup cycle. If set to less than 1, the value is ignored."
  default     = 5
  type        = number
}

variable "ecs_enable_container_metadata" {
  description = "When true, the agent creates a file describing the container's metadata. The file can be located and consumed by using the container environment variable $ECS_CONTAINER_METADATA_FILE."
  default     = true
  type        = bool
}

variable "ecs_container_start_timeout" {
  description = "Time duration to wait before giving up on starting a container."
  default     = "3m"
  type        = string
}

variable "ecs_container_stop_timeout" {
  description = "Time duration to wait from when a task is stopped before its containers are forcefully killed if they do not exit normally on their own."
  default     = "30s"
  type        = string
}

variable "ecs_enable_spot_instance_draining" {
  description = "Whether to enable Spot Instance draining for the container instance."
  default     = false
  type        = bool
}

variable "ecs_disable_privileged" {
  description = "Whether launching privileged containers is disabled on the container instance. If this value is set to true, privileged containers are not permitted."
  default     = false
  type        = bool
}

variable "ecs_selinux_capable" {
  description = "Whether SELinux is available on the container instance."
  default     = false
  type        = bool
}

variable "ecs_apparmor_capable" {
  description = "Whether AppArmor is available on the container instance."
  default     = false
  type        = bool
}

variable "ecs_engine_task_cleanup_wait_duration" {
  description = "Time duration to wait from when a task is stopped until the Docker container is removed. As this removes the Docker container data, be aware that if this value is set too low, you may not be able to inspect your stopped containers or view the logs before they are removed. The minimum duration is 1m; any value shorter than 1 minute is ignored."
  default     = "3h"
  type        = string
}

variable "ecs_http_proxy" {
  description = "The hostname (or IP address) and port number of an HTTP proxy to use for the ECS agent to connect to the internet (for example, if your container instances do not have external network access through an Amazon VPC internet gateway or NAT gateway or instance). If this variable is set, you must also set the NO_PROXY variable to filter EC2 instance metadata and Docker daemon traffic from the proxy."
  default     = ""
  type        = string
}

variable "ecs_no_proxy" {
  description = "The HTTP traffic that should not be forwarded to the specified HTTP_PROXY. You must specify 169.254.169.254,/var/run/docker.sock to filter EC2 instance metadata and Docker daemon traffic from the proxy."
  default     = ""
  type        = string
}

variable "ecs_enable_task_eni" {
  description = "Whether to enable task networking for tasks to be launched with their own network interface."
  default     = false
  type        = bool
}

variable "ecs_cni_plugins_path" {
  description = "The path where the cni binary file is located."
  default     = "/amazon-ecs-cni-plugins"
  type        = string
}

variable "ecs_disable_docker_health_check" {
  description = "Whether to disable the Docker container health check for the ECS Agent."
  default     = false
  type        = bool
}

variable "ecs_agent_loglevel" {
  description = "The level to log at on stdout for esc agent."
  default     = "info"
  type        = string
}

variable "ecs_datadir" {
  description = "The name of the persistent data directory on the container that is running the Amazon ECS container agent. The directory is used to save information about the cluster and the agent state."
  default     = "/data"
  type        = string
}

variable "alarm_cpu_scale_up_threshold" {
  description = "The CPU consumption threshold of the instance group that triggers an increase in the number of instances in the instance group"
  type        = number
  default     = 90
}

variable "alarm_cpu_scale_up_period" {
  description = "The CPU period of the instance group that triggers an increase in the number of instances in the instance group"
  type        = number
  default     = 180
}

variable "alarm_cpu_scale_down_period" {
  description = "The CPU period of the instance group that triggers an increase in the number of instances in the instance group"
  type        = number
  default     = 180
}

variable "alarm_memory_scale_up_period" {
  description = "The memory period of the instance group that triggers an increase in the number of instances in the instance group"
  type        = number
  default     = 180
}

variable "alarm_memory_scale_down_period" {
  description = "The memory period of the instance group that triggers an increase in the number of instances in the instance group"
  type        = number
  default     = 180
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

variable "alarm_scale_up_scaling_adjustment" {
  description = "For Alarms scale up, the number of instances by which to scale. adjustment_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity"
  default     = 1
  type        = number
}

variable "alarm_scale_down_scaling_adjustment" {
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

variable "efs_volume" {
  description = "The EFS volume to attach to ec2 instances. ( ex : fs-05a856xx)"
  type        = string
  default     = ""
}

variable "efs_mount_point" {
  description = "The EFS volume mount point for EC2 instances."
  type        = string
  default     = "/mnt/efs"
}

variable "ebs_volume_size" {
  description = "The EBS size of volume for ESC data dir"
  type        = number
  default     = 0
}

variable "ebs_volume_type" {
  description = "The type of volume. Can be 'standard', 'gp2', or 'io1'."
  type        = string
  default     = "standard"
}

variable "ebs_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination (Default: false). See Preserving Amazon EBS Volumes on Instance Termination for more information."
  type        = bool
  default     = false
}

variable "ebs_kms_key_id" {
  description = "AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. encrypted must be set to true when this is set."
  type        = string
  default     = ""
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  type        = bool
  default     = false
}

variable "cron_definition_restart_ecs_demon" {
  description = "The cron définition for restart ecs daemon for sts management(default every 6 hours)"
  type        = string
  default     = "0 */6 * * *"
}

variable "enable_monitoring" {
  description = "If true, the launched EC2 instance cluster node will have detailed monitoring enabled."
  type        = bool
  default     = true
}

variable "cloudwatch_agent_metrics_collection_interval" {
  description = "Specifies how often to collect the cpu metrics, overriding the global metrics_collection_interval specified in the agent section of the configuration file. If you set this value below 60 seconds, each metric is collected as a high-resolution metric."
  type        = number
  default     = 60
}

variable "cloudwatch_agent_metrics_disk_resources" {
  description = "Specifies an array of disk mount points. This field limits CloudWatch to collect metrics from only the listed mount points. You can specify * as the value to collect metrics from all mount points. Defaults to the root / mountpount."
  type        = list(string)
  default     = ["/"]
}

variable "cloudwatch_agent_metrics_cpu_resources" {
  description = "Specifies that per-cpu metrics are to be collected. The only allowed value is *. If you include this field and value, per-cpu metrics are collected."
  type        = string
  default     = "\"resources\": [\"*\"],"
}

variable "cloudwatch_agent_metrics_config" {
  description = "Which metrics should we send to cloudwatch, the default is empty. If the value is empty then  clouwatch agent is not installed .Setting this variable to advanced will send all the available metrics that are provided by the agent. You can find more information here https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-cloudwatch-agent-configuration-file-wizard.html. The valids values are  : <empty> / minimal /standard / advanced or custom."
  type        = string
  default     = ""
}

variable "cloudwatch_agent_metrics_custom_config_content" {
  description = "The content of cloudwatch agent config if cloudwatch_agent_metrics_config = custom"
  type        = string
  default     = ""
}

variable "auto_restart_ecs_agent" {
  type        = bool
  default     = false
  description = "Auto restart ECS cluster Agent if the container instance loose sts crendentials for pull image from ECR."
}
