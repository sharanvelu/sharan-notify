#!/bin/bash

set -e

IMAGE="${ECR_REPOSITORY_URL}:${IMAGE_ID}"

echo ""
echo -e "AWS Log Group  : ${AWS_LOG_GROUP}"
echo -e "Container Name : ${CONTAINER_NAME}"
echo -e "Task Role ARN  : ${TASK_ROLE_ARN}"
echo -e "Image URI      : ${IMAGE}\n"

IMAGE_PLACEHOLDER="<img>"
ENV_FILE_PLACEHOLDER="<env-file>"
CPU_PLACEHOLDER="\"<cpu>\""
MEMORY_PLACEHOLDER="\"<memory>\""
MEMORY_RES_PLACEHOLDER="\"<memory-reservation>\""
CONTAINER_NAME_PLACEHOLDER="<container-name>"
AWS_LOG_GROUP_PLACEHOLDER="<aws-log-group>"

CONTAINER_DEFINITION_FILE=$(cat docker-deployment/container-definition.json)

CONTAINER_DEFINITION="${CONTAINER_DEFINITION_FILE//${IMAGE_PLACEHOLDER}/${IMAGE}}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//${AWS_LOG_GROUP_PLACEHOLDER}/${AWS_LOG_GROUP}}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//${CONTAINER_NAME_PLACEHOLDER}/${CONTAINER_NAME}}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//${ENV_FILE_PLACEHOLDER}/${ENV_FILE_S3}}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//${CPU_PLACEHOLDER}/${CPU}}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//${MEMORY_PLACEHOLDER}/${MEMORY}}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//${MEMORY_RES_PLACEHOLDER}/${MEMORY_RES}}"

export TASK_VERSION=$(aws ecs register-task-definition --family ${TASK_DEFINITION} --container-definitions "${CONTAINER_DEFINITION}" --execution-role-arn ${TASK_ROLE_ARN} --task-role-arn ${TASK_ROLE_ARN} --network-mode bridge --requires-compatibilities EC2 --tags key="commit",value=$IMAGE_ID | jq --raw-output '.taskDefinition.revision')
echo -e "TDF Version    : ${TASK_VERSION:---nil--}"

if [ -n "${TASK_VERSION}" ]; then
    echo -e "ECS Cluster    : ${CLUSTER_NAME}"
    echo -e "ECS Service    : ${SERVICE_NAME}"
    echo -e "Task Definition: ${TASK_DEFINITION}:${TASK_VERSION}\n"

    DEPLOYED_SERVICE=$(aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition ${TASK_DEFINITION}:${TASK_VERSION} --force-new-deployment | jq --raw-output '.service.serviceName')
    echo -e "${CLUSTER_NAME} => ${DEPLOYED_SERVICE} : Deployed Successfully!"

else
    echo "exit: Unable to register new task definition or version."
    exit;
fi
