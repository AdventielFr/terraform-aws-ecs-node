--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/usr/bin/env bash
# Install amazon efs utils
yum install -y amazon-efs-utils nfs-utils

DIR_TGT="${efs_volume}"
DIR_SRC="${efs_mount_point}"
#Create mount point
mkdir -p $DIR_TGT
#Mount EFS file system
mount -t nfs4 $DIR_SRC:/ $DIR_TGT
#Backup fstab
cp -p /etc/fstab /etc/fstab.back-$(date +%F)
#Append line to fstab
echo -e "$DIR_SRC:/ \t\t $DIR_TGT \t\t nfs \t\t defaults \t\t 0 \t\t 0" | tee -a /etc/fstab
