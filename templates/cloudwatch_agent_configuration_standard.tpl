{
  "agent": {
    "run_as_user": "cwagent"
  },
  "metrics": {
    "append_dimensions": {
      "ImageId": "$${aws:ImageId}",
      "InstanceId": "$${aws:InstanceId}",
      "InstanceType": "$${aws:InstanceType}",
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}"
    },
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": ${metrics_collection_interval},
        ${cpu_resources}
        "totalcpu": true
      },
      "disk": {
        "measurement": [
          "used_percent",
          "inodes_free"
        ],
        "metrics_collection_interval": ${metrics_collection_interval},
        "resources": ${disk_resources}
      },
      "diskio": {
        "measurement": [
          "io_time"
        ],
        "metrics_collection_interval": ${metrics_collection_interval},
        "resources": ${disk_resources}
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": ${metrics_collection_interval}
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": ${metrics_collection_interval}
      }
    }
  }
}
