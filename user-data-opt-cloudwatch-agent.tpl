--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/usr/bin/env bash

# download cloudwatch-agent
yum install -y https://s3.${region}.amazonaws.com/amazoncloudwatch-agent-${region}/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm

# create cloudwatch-agent configuration file
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<- EOF
${cloudwatch_agent_config_content}
EOF

# start cloudwatch-agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
