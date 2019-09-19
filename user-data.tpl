Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/usr/bin/env bash
# Install awslogs and the jq JSON parser
yum install -y awslogs jq

# Setting info for ECS cluster configuration
echo ECS_CLUSTER="${ecs_cluster_name}" >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS=[\"json-file\",\"syslog\",\"awslogs\"] >> /etc/ecs/ecs.config
echo AWS_DEFAULT_REGION=${aws_region} >> /etc/ecs/ecs.config
echo ECS_LOGLEVEL=${ecs_agent_loglevel} >> /etc/ecs/ecs.config
echo ECS_INSTANCE_ATTRIBUTES="{\"ECSGroup\":\"${ecs_group_node}\"}" >> /etc/ecs/ecs.config
echo ECS_IMAGE_PULL_BEHAVIOR=${ecs_image_pull_behavior} >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=${ecs_enable_task_iam_role} >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=${ecs_enable_task_iam_role_network_host} >> /etc/ecs/ecs.config

# Inject the CloudWatch Logs configuration file contents
cat > /etc/awslogs/awslogs.conf <<- EOF
[general]
state_file = /var/lib/awslogs/agent-state        
 
[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = /aws/ecs/${ecs_cluster_name}/node/${ecs_group_node}/var/log/dmesg
log_stream_name = {container_instance_id}

[/var/log/messages]
file = /var/log/messages
log_group_name = /aws/ecs/${ecs_cluster_name}/node/${ecs_group_node}/var/log/messages
log_stream_name = {container_instance_id}
datetime_format = %b %d %H:%M:%S

[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log*
log_group_name = /aws/ecs/${ecs_cluster_name}/node/${ecs_group_node}/var/log/ecs/ecs-init.log
log_stream_name = {container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log.*
log_group_name = /aws/ecs/${ecs_cluster_name}/node/${ecs_group_node}/var/log/ecs/ecs-agent.log
log_stream_name = {container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/audit.log]
file = /var/log/ecs/audit.log.*
log_group_name = /aws/ecs/${ecs_cluster_name}/node/${ecs_group_node}/var/log/ecs/audit.log
log_stream_name = {container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

EOF

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/usr/bin/env bash
cat > /etc/logrotate.d/ecs-init <<- 'EOF'
/var/log/ecs/ecs-init.log* {
    rotate 24
    daily
}
EOF

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/usr/bin/env bash
# Write the awslogs bootstrap script to /usr/local/bin/bootstrap-awslogs.sh
cat > /usr/local/bin/bootstrap-awslogs.sh <<- 'EOF'
#!/usr/bin/env bash
exec 2>>/var/log/ecs/cloudwatch-logs-start.log
set -x

until curl -s curl -s 169.254.169.254/latest/dynamic/instance-identity/document
do
	sleep 1	
done

# Set the region to send CloudWatch Logs data to (the region where the container instance is located)
cp /etc/awslogs/awscli.conf /etc/awslogs/awscli.conf.bak
region=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
sed -i -e "s/region = .*/region = $region/g" /etc/awslogs/awscli.conf

# Grab the cluster and container instance ARN from instance metadata
container_instance_id=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .instanceId)

# Replace the cluster name and container instance ID placeholders with the actual values
cp /etc/awslogs/awslogs.conf /etc/awslogs/awslogs.conf.bak
sed -i -e "s/{container_instance_id}/$container_instance_id/g" /etc/awslogs/awslogs.conf
EOF

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/usr/bin/env bash
# Write the bootstrap-awslogs systemd unit file to /etc/systemd/system/bootstrap-awslogs.service
cat > /etc/systemd/system/bootstrap-awslogs.service <<- EOF
[Unit]
Description=Bootstrap awslogs agent
Requires=ecs.service
After=ecs.service
Before=awslogsd.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/bootstrap-awslogs.sh

[Install]
WantedBy=awslogsd.service
EOF

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/sh
chmod +x /usr/local/bin/bootstrap-awslogs.sh
systemctl daemon-reload
systemctl enable bootstrap-awslogs.service
systemctl enable awslogsd.service
systemctl start awslogsd.service --no-block

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/usr/bin/env bash
# Install the SSM agent RPM
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/sh
systemctl daemon-reload
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/sh
#write out current crontab
crontab -l > ecs_restart
#echo new cron into cron file
echo "*/5 * * * * systemctl restart ecs" >> ecs_restart
#install ecs_restart file
crontab ecs_restart

${user_data_option_efs}
