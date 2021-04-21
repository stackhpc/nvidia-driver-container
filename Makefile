FEDORA_VERSION = 32
KERNEL_VERSION = 5.8.15-201.fc32.x86_64
ARCH = x86_64
NVIDIA_DRIVER_VERSION = 455.28

IMAGE ?= fedora

export CONTAINER_TAG ?= ghcr.io/stackhpc/nvidia-driver-installer:$(KERNEL_VERSION)-$(NVIDIA_DRIVER_VERSION)

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
	echo "Building Docker Image ... "
	docker build \
	  --rm=false \
	  --network=host \
	  --build-arg FEDORA_VERSION=$(FEDORA_VERSION) \
	  --build-arg KERNEL_VERSION=$(KERNEL_VERSION) \
	  --build-arg NVIDIA_DRIVER_VERSION=$(NVIDIA_DRIVER_VERSION) \
	  --build-arg ARCH=$(ARCH) \
	  --tag $(CONTAINER_TAG) \
	  --file Dockerfile.$(IMAGE) .

push: build
	if [ "$(DOCKER_USERNAME)" != "" ]; then \
		echo "$(DOCKER_PASSWORD)" | docker login --username="$(DOCKER_USERNAME)" --password-stdin; \
	fi; \
	docker push $(CONTAINER_TAG)

.PHONY: validate build push
