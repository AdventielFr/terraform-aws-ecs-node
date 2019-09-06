{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowS3AccessListingSharedFolder",
        "Action": [
            "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": ["arn:aws:s3:::${bucket_restriction}"]
      },
      {
        "Sid": "AllowS3AccessObjectSharedFolder",
        "Effect": "Allow",
        "Action": [
            "s3:*Object"
        ],
        "Resource": [
          "arn:aws:s3:::${bucket_restriction}/in/*",
          "arn:aws:s3:::${bucket_restriction}/out/*",
          "arn:aws:s3:::${bucket_restriction}/tmp/*"
        ]
      },
      {
        "Sid": "AllowCloudWatchLogs",
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        "Resource": [
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  }