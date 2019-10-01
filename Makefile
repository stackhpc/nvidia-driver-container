FEDORA_VERSION = 29
KERNEL_VERSION = "4.19.3-300.fc29.x86_64"
NVIDIA_DRIVER_VERSION="430.50" 

CONTAINER_TAG ?= gitlab-registry.cern.ch/cloud/atomic-system-containers/nvidia-driver-installer:$(FEDORA_VERSION)-$(KERNEL_VERSION)-$(NVIDIA_DRIVER_VERSION)

validate:
	@if [ -z "$(NVIDIA_DRIVER_VERSION)" ]; then \
		echo "NVIDIA_DRIVER_VERSION cannot be empty, automatic detection has failed."; \
		exit 1; \
	fi;
	@if [ -z "$(KERNEL_VERSION)" ]; then \
		echo "KERNEL_VERSION cannot be empty, automatic detection has failed."; \
		exit 1; \
	fi;

build: validate
	echo "Building Docker Image ... " && \
	docker build \
		--rm=false \
		--network=host \
		--build-arg FEDORA_VERSION=$(FEDORA_VERSION) \
		--build-arg KERNEL_VERSION=$(KERNEL_VERSION) \
		--build-arg NVIDIA_DRIVER_VERSION=$(NVIDIA_DRIVER_VERSION) \
		--tag $(CONTAINER_TAG) \
		--file Dockerfile .

push: build
	if [ "$(DOCKER_USERNAME)" != "" ]; then \
		echo "$(DOCKER_PASSWORD)" | docker login --username="$(DOCKER_USERNAME)" --password-stdin; \
	fi; \
	docker push $(CONTAINER_TAG)

.PHONY: validate build push
