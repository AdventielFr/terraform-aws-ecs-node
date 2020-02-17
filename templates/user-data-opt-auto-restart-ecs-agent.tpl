--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/usr/bin/env bash
yum install -y python3 python-pip
pip install --upgrade pip
pip3 install goto-statement
pip3 install pygtail

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/usr/bin/env bash
mkdir -f /var/log/ecs
# Write the file to /usr/bin
cat > /usr/bin/auto-restart-ecs.py <<- EOF
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import re
import os.path
import time
import logging
from logging.handlers import RotatingFileHandler
from pygtail import Pygtail
from goto import with_goto

@with_goto
def main():

    wait_time = 5
    watch_file='/var/log/ecs/ecs-agent.log'
    log_file = '/var/log/ecs/auto-restart-ecs.log'
    pattern = "^level=info.+default\s->\sSTOPPED,\sReason\sCannotPullContainerError:\sError\sresponse\sfrom\sdaemon:\spull\saccess\sdenied\sfor\s\d{12}\.dkr\.ecr\.[a-z-0-9]+\.amazonaws.com\/[^,]+, repository\sdoes\snot\sexist\sor\smay\srequire\s'docker\slogin'"

    logger = logging.getLogger('')
    logger.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler = RotatingFileHandler(log_file,maxBytes=10000, backupCount=10)
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    label .start
    
    while not os.path.exists(watch_file):
        logger.info(f'Wait {wait_time}s ,{watch_file} not exist.')
        time.sleep(wait_time)

    logger.info(f'Starting scan {watch_file} ...')
    try:
        if os.path.exists(watch_file+'.offset'):
            os.remove(watch_file+'.offset')
        pygtail = Pygtail(watch_file)
        while True:
            line = pygtail.read()
            if line and re.match(pattern,str(line)):
                logger.info('Try to restart esc service ...')
                exit_code = os.system('systemctl restart ecs')
                if exit_code !=0 :
                    logger.info(f'Fail to restart ecs service ( exit code : {exit_code} )')
                else:
                    logger.info(f'Success to restart ecs service')
 
    except FileNotFoundError as e:
        goto .start

if __name__ == '__main__':
    main()
EOF

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/usr/bin/env bash
# Write the auto-restart-ecs systemd unit file to /etc/systemd/system/auto-restart-ecs.service
cat > /etc/systemd/system/auto-restart-ecs.service <<- EOF
[Unit]
Description=Auto restart ecs Sevice 
After=multi-user.target
Conflicts=getty@tty1.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/bin/auto-restart-ecs.py
StandardInput=tty-force

[Install]
WantedBy=multi-user.target

EOF

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/sh
chmod +x /usr/bin/auto-restart-ecs.py
systemctl daemon-reload
systemctl enable auto-restart-ecs.service
systemctl start auto-restart-ecs --no-block