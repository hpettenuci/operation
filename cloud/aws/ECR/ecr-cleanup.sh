#!/bin/bash
set -e

AWS_PROFILE=""
AWS_REGION=""
AWS_REGISTRY_ID=""

DOCKER_IMAGE_PREFIX=""
DOCKER_IMAGE_VERSION="UNTAGGED"

REPO_LIST=$(aws ecr describe-repositories --max-items 500 --registry-id ${AWS_REGISTRY_ID} --profile ${AWS_PROFILE} --region ${AWS_REGION} | jq -r ".repositories[] | select(.repositoryName | startswith(\"${DOCKER_IMAGE_PREFIX}\")) | .repositoryName")

for REPO in $REPO_LIST ; do
    echo $REPO
    IMAGE_LIST=$(aws ecr describe-images --repository-name "${REPO}" --filter tagStatus=${DOCKER_IMAGE_VERSION} --profile ${AWS_PROFILE} --region ${AWS_REGION} | jq -r '.imageDetails[].imageDigest')

    if [ IMAGE_LIST != "" ] ; then
        for IMAGE in $IMAGE_LIST ; do
            aws ecr batch-delete-image --repository-name "${REPO}" --image-ids imageDigest=${IMAGE} --profile ${AWS_PROFILE} --region ${AWS_REGION}
        done
    fi
done
