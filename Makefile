SHELL=/bin/bash
PATH := .venv/bin:$(PATH)
export IMG_NAME?=sm-studio-custom-python310
export IMAGE_TAG?=latest
export ENV?=dev
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=789524919849
export ECR_URL=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

install:
	@( \
		if [ ! -d .venv ]; then python3 -m venv --copies .venv; fi; \
		source .venv/bin/activate; \
		pip install -qU pip; \
	)

setup:
	@if [ ! -f .env ] ; then cp .env.mock .env ; fi;
	@make install;

build:
	@docker build --platform=linux/amd64 -t ${IMG_NAME} .

local-build:
	@docker build -t ${IMG_NAME} .

to-ecr:
	@$(shell ./push_ecr.sh ${AWS_ACCOUNT_ID} ${AWS_REGION} ${REPO_NAME})

promote:
	@$(shell aws ecr get-login --no-include-email --region ${AWS_REGION} --registry-ids ${AWS_ACCOUNT_ID} )
	@docker tag ${IMG_NAME} ${ECR_URL}/${IMG_NAME}:${IMAGE_TAG}
	@docker push ${ECR_URL}/${IMG_NAME}

promote2:
    $(eval ECR_REPO_EXISTS := $(shell aws ecr describe-repositories --repository-names ${IMG_NAME} 2>/dev/null))
    @if [ -z "${ECR_REPO_EXISTS}" ]; then \
        aws ecr create-repository --repository-name ${IMG_NAME}; \
    fi
    @$(shell aws ecr get-login --no-include-email --region ${AWS_REGION} --registry-ids ${AWS_ACCOUNT_ID} )
    @docker tag ${IMG_NAME} ${ECR_URL}/${IMG_NAME}:${IMAGE_TAG}
    @docker push ${ECR_URL}/${IMG_NAME}

img-tag:
	@docker tag ${IMG_NAME} ${ECR_URL}/${IMG_NAME}:${IMAGE_TAG}

run:
	@docker run -it ${IMG_NAME} bash
