SHELL=/bin/bash
ALGO_CONFIGS=$(shell psec environments path configs)

## docker-build: Build and tag a docker image
.PHONY: docker-build

IMAGE          := trailofbits/algo
TAG	  	       := latest
DOCKERFILE     := Dockerfile
CONFIGURATIONS := $(shell pwd)

docker-build:
	psec -E run -- docker build \
	-t $(IMAGE):$(TAG) \
	-f $(DOCKERFILE) \
	.

## docker-deploy: Mount config directory and deploy Algo
.PHONY: docker-deploy

# '--rm' flag removes the container when finished.
docker-deploy:
	psec -E run -- docker run \
	--cap-drop=all \
	--rm \
	-it \
	-v $(CONFIGURATIONS):/data \
	$(IMAGE):$(TAG)

## docker-clean: Remove images and containers.
.PHONY: docker-prune

docker-prune:
	psec -E run -- docker images \
	$(IMAGE) |\
	awk '{if (NR>1) print $$3}' |\
	xargs docker rmi

## docker-all: Build, Deploy, Prune
.PHONY: docker-all

docker-all: docker-build docker-deploy docker-prune

## psec-configure: Set up python_secrets variables
.PHONY: psec-configure


.PHONY: psec-init
psec-init:
	@if [ "$(shell psec secrets get algo_provider)" == "None" ]; \
	then \
		psec secrets set --undefined; \
	fi
	@if [ "$(shell psec secrets get algo_provider)" == "None" ]; \
	then \
		echo 'algo_provider not defined: exiting'; exit 1; \
	fi
	@echo 'algo_provider is defined'

.PHONY: psec-provider-init
psec-provider-init:
	@echo 'not implemented yet...'


.PHONY: deploy
deploy:
	psec -E run -- bash algo
