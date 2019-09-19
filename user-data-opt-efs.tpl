--==BOUNDARY==
Content-Type: text/cloud-boothook; charset="us-ascii"

# Install amazon-efs-utils
cloud-init-per once yum_update yum update -y
cloud-init-per once install_amazon-efs-utils yum install -y amazon-efs-utils

# Create ${efs_mount_point} folder
cloud-init-per once mkdir_efs mkdir ${efs_mount_point}

# Mount ${efs_mount_point}
cloud-init-per once mount_efs echo -e '${efs_volume}:/ ${efs_mount_point} efs defaults,_netdev 0 0' >> /etc/fstab
mount -a