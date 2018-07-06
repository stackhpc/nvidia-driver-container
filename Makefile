FEDORA_VERSION = 27
KERNEL_VERSION = "4.15.4-300.fc27.x86_64"
NVIDIA_DRIVER_VERSION="396.24" 

# Environment
WORKDIR := $(PWD)

# Docker configuration
DOCKER_REGISTRY ?= gitlab-registry.cern.ch
DOCKER_ORG ?= kosamara
DOCKER_REPOSITORY ?= nvidia-system-container
CONTAINER_NAME ?= nvidia-driver-installer
DOCKER_USERNAME ?= kosamara
DOCKER_PASSWORD ?=

CONTAINER_TAG ?= $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(DOCKER_REPOSITORY)/$(CONTAINER_NAME):$(FEDORA_VERSION)

validate:
	@if [ -z "$(NVIDIA_DRIVER_VERSION)" ]; then \
		echo "NVIDIA_DRIVER_VERSION cannot be empty, automatic detection has failed."; \
		exit 1; \
	fi;
	@if [ -z "$(KERNEL_VERSION)" ]; then \
		echo "KERNEL_VERSION cannot be empty, automatic detection has failed."; \
		exit 1; \
	fi;
	@if [ -z "$(DOCKER_ORG)" ]; then \
		echo "DOCKER_ORG cannot be empty."; \
		exit 1; \
	fi;

build: validate
	echo "Building Docker Image ..." && \
	docker build \
		--rm=false \
		--network=host \
		--build-arg FEDORA_VERSION=$(FEDORA_VERSION) \
		--build-arg KERNEL_VERSION=$(KERNEL_VERSION) \
		--build-arg NVIDIA_DRIVER_VERSION=$(NVIDIA_DRIVER_VERSION) \
		--tag $(CONTAINER_TAG) \
		--file $(WORKDIR)/Dockerfile .

push: build
	if [ "$(DOCKER_USERNAME)" != "" ]; then \
		echo "$(DOCKER_PASSWORD)" | docker login --username="$(DOCKER_USERNAME)" --password-stdin; \
	fi; \
	docker push $(CONTAINER_TAG)

.PHONY: validate build push
