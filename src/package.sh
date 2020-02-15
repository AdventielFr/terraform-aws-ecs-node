#!/bin/sh

#----------------------------
# build and package lambda
#----------------------------

rm -rf .serverless/ || true
sls plugin install --name serverless-iam-roles-per-function
sls plugin install --name serverless-plugin-log-retention
sls plugin install --name serverless-python-requirements
sls plugin install --name serverless-python-requirements
sls plugin install --name serverless-pseudo-parameters
sls package --name lambda_function_payload
rm -f ../auto-update-ecs-cluster-agent.zip || true
mv .serverless/auto-update-ecs-cluster-agent.zip ../
rm -rf .serverless/