#!/bin/bash
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
echo "Account ID is "$ACCOUNT
DOCKER_CONTAINER=encoding-batch-job
REPO=${ACCOUNT}.dkr.ecr.eu-west-1.amazonaws.com/${DOCKER_CONTAINER}
echo "Target repository is ${REPO}"
TAG=build-1.0.1
echo "Building Docker Image..."
docker build -t $DOCKER_CONTAINER .
echo "Authenticating against AWS ECR..."
eval $(aws ecr get-login --no-include-email --region eu-west-1)
echo "Creating repository ${DOCKER_CONTAINER} if needed"
aws ecr create-repository --repository-name $DOCKER_CONTAINER --region eu-west-1
echo "Tagging ${REPO}..."
docker tag $DOCKER_CONTAINER:latest $REPO:$TAG
docker tag $DOCKER_CONTAINER:latest $REPO:latest
echo "Deploying to AWS ECR"
docker push $REPO