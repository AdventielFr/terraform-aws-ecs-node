
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import boto3
import os
import logging
import urllib
import json
import time
import traceback

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def main(event, context):
    try:
        client = boto3.client('ecs')
        cluster_name = get_cluster_name()
        container_instance_group_node = get_container_instance_group_node() 
        agent_version = get_last_agent_version()
        logger.info(agent_version)
        filter_container_instances = get_filter_container_instances(agent_version, container_instance_group_node )
        logger.info(filter_container_instances)
        container_instances = get_container_instances(cluster_name,filter_container_instances)
        if container_instances:
            update_agent_container_instances(cluster_name, container_instances)
        else:
            logger.info('ECS Agent is update to date for Container intances')
    except Exception as e:
        stack_trace = traceback.format_exc()
        logger.error(stack_trace)
        send_message(f"Fail to update ESC agent, reason : {e}", verbosity='ERROR')

def get_last_agent_version():
    url = "https://api.github.com/repos/aws/amazon-ecs-agent/releases/latest"
    with urllib.request.urlopen(url) as request:
        data = json.loads(request.read().decode())
        return data['tag_name'][1:]

def get_filter_container_instances(agent_version, container_instance_group_node):
    result = f'agentVersion < {agent_version}'
    if container_instance_group_node:
        result += f" and attribute:EcsGroupNode == {container_instance_group_node}"
    return result

def get_region():
    return os.environ.get('AWS_REGION')

def get_cluster_name():
    return os.environ.get('ECS_CLUSTER_NAME')

def get_container_instance_group_node():
    return os.environ['ECS_GROUP_NODE']

def get_container_instances(client, cluster_name, filter_instances, nextToken=None):
    result = []
    response = None
    if not nextToken:
        response = client.list_container_instances( cluster = cluster_name, filter = filter_instances, status = 'ACTIVE' )
    else:
        response = client.list_container_instances( cluster = cluster_name, filter = filter_instances, nextToken = nextToken, status = 'ACTIVE' )
    if 'containerInstanceArns' in response:
        result += response['containerInstanceArns']
    if 'nextToken' in response:
        result += get_container_instances(client, cluster_name, filter_instances, response['nextToken'])
    return result       

def update_agent_container_instance(client,  cluster_name, container_instance):
    response = client.update_container_agent(
                    cluster = cluster_name,
                    containerInstance = container_instance
                )
    state = response['containerInstance']['agentUpdateStatus']
    logger.info(f'{container_instance} agent state: {state}')
    while True:
        response = client.describe_container_instances(
            cluster = cluster_name,
            containerInstances = [ container_instance]
        )
        state = response['containerInstances'][0]['agentUpdateStatus']
        logger.info(f'Ecs Agent update {container_instance} - {state}')
        if state == 'UPDATED':
            send_message(f"Success to update ESC agent, containerInstance: {container_instance}, cluster :{cluster_name}", verbosity='INFO')
        elif state ==' FAILED':
            send_message(f"Fail to update ESC agent, containerInstance: {container_instance}, cluster :{cluster_name}", verbosity='ERROR')
            return
        else:
            time.sleep(2)
 
def update_agent_container_instances(client, cluster_name, container_instances):
    for container_instance in container_instances:
        update_agent_container_instance(client, cluster_name, container_instance)

def send_message(self, message, verbosity = 'INFO'):
    """send message to sns topic"""
    sns_client = boto3.client('sns')
    aws_sns_result_arn = os.environ.get('AWS_SNS_RESULT_ARN')
    return sns_client.publish(TopicArn=aws_sns_result_arn, Message=f'[{verbosity}]:{message}')