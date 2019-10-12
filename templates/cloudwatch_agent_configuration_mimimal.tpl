{
  "agent": {
    "run_as_user": "cwagent"
  },
  "metrics": {
    "append_dimensions": {
      "ImageId": "\$${aws:ImageId}",
      "InstanceId": "\$${aws:InstanceId}",
      "InstanceType": "\$${aws:InstanceType}",
      "AutoScalingGroupName": "\$${aws:AutoScalingGroupName}"
    },
    "metrics_collected": {
      "cpu": {
        "metrics_collection_interval": ${metrics_collection_interval},
        "totalcpu": true
      },
      "disk": {
        "measurement": [
          "disk_used_percent"
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
