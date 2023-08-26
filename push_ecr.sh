#!/usr/bin/env bash

if [ $# -lt 2 ]
then
  echo "usage: push_ecr.sh <aws_acct_id> <aws_region> <repo_name>"
  exit 1
fi

aws_account_id=$1
region=$2
repo_name=$3
export AWS_DEFAULT_REGION=${region}

version="latest"
image_name="${repo_name}:${version}"

docker buildx build --platform=linux/amd64 -t ${image_name} .
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${region}.amazonaws.com

if aws ecr describe-repositories --repository-names ${repo_name}; then
  echo "Repository exists."
else
  echo "Repository doesn't exist. Creating one now."
  aws ecr create-repository \
    --repository-name  ${repo_name} \
    --image-scanning-configuration scanOnPush=true \
    --region ${region}
fi

set -e

docker tag ${image_name} ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${image_name}
docker push ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${image_name}
echo "Docker Image ${aws_account_id}.dkr.ecr.${region}.amazonaws.com/${image_name} has been push to ECR successfully"
