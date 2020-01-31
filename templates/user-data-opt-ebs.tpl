--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
mkfs -t ext4 ${ebs_device}
mkdir ${ecs_datadir}
mount ${ebs_device} ${ecs_datadir}
echo "${ebs_device} ${ecs_datadir}   ext4    defaults,nofail    0    2" >> /etc/fstab 

