#!/bin/bash

set -e

TASK_FAMILY=$TASK_DEFINITION
SERVICE_NAME=$SERVICE_NAME
CLUSTER_NAME=$CLUSTER_NAME
CPU_ENV=$CPU
MEMORY_ENV=$MEMORY
IMG_VERSION=$CODEBUILD_RESOLVED_SOURCE_VERSION
IMAGE=${ECR_REPOSITORY_URL}:${IMG_VERSION}
ENV_FILE=${ENVFILE_S3}


echo "AWS Log Group : ${AWS_LOG_GROUP}"
echo "Container Name : ${CONTAINER_NAME}"
echo "Task Role ARN : ${TASK_ROLE_ARN}"

IMAGE_PLACEHOLDER="<IMG>"
ENV_FILE_PLACEHOLDER="<env-file>"
CPU_PLACEHOLDER="\"<cpu>\""
MEMORY_PLACEHOLDER="\"<memory>\""
MEMORY_RES_PLACEHOLDER="\"<memory-reservation>\""
CONTAINER_NAME_PLACEHOLDER="<container-name>"
AWS_LOG_GROUP_PLACEHOLDER="<aws-log-group>"


CONTAINER_DEFINITION_FILE=$(cat docker-deployment/container-definition.json)
CONTAINER_DEFINITION="${CONTAINER_DEFINITION_FILE//$IMAGE_PLACEHOLDER/$IMAGE}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//$AWS_LOG_GROUP_PLACEHOLDER/$AWS_LOG_GROUP}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//$CONTAINER_NAME_PLACEHOLDER/$CONTAINER_NAME}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//$ENV_FILE_PLACEHOLDER/$ENV_FILE}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//$CPU_PLACEHOLDER/$CPU_ENV}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//$MEMORY_PLACEHOLDER/$MEMORY_ENV}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//$MEMORY_RES_PLACEHOLDER/$MEMORYRES}"

export TASK_VERSION=$(aws ecs register-task-definition --family ${TASK_FAMILY} --container-definitions "${CONTAINER_DEFINITION}" --execution-role-arn ${TASK_ROLE_ARN} --task-role-arn ${TASK_ROLE_ARN} --network-mode bridge --requires-compatibilities EC2 --tags key="commit",value=$CODEBUILD_RESOLVED_SOURCE_VERSION | jq --raw-output '.taskDefinition.revision')
echo "Registered ECS Task Definition: " $TASK_VERSION


if [ -n "$TASK_VERSION" ]; then
    echo "Update ECS Cluster: " $CLUSTER_NAME
    echo "Service: " $SERVICE_NAME
    echo "Task Definition: " $TASK_FAMILY:$TASK_VERSION

    DEPLOYED_SERVICE=$(aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $TASK_FAMILY:$TASK_VERSION --force-new-deployment | jq --raw-output '.service.serviceName')
    echo "Deployment of service \"$DEPLOYED_SERVICE\" complete!!"

else
    echo "exit: No task definition"
    echo "Deleting the created Image..."
    OUTPUT=$(aws ecr batch-delete-image --repository-name ${ECR_REPO_NAME} --image-ids imageTag=${IMG_VERSION})
    echo "Created Image deleted..."
    exit;
fi
