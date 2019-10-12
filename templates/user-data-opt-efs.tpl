--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/usr/bin/env bash
# Install amazon efs utils
yum install -y amazon-efs-utils
	
# create directory for mount point efs
mkdir -p ${efs_mount_point}
echo "${efs_volume}:/ ${efs_mount_point} efs tls,_netdev" >> /etc/fstab
mount -a -t efs defaults
chmod 777 ${efs_mount_point}