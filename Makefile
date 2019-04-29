##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

VERSIONS = 5.5.3 5.6.14

ELASTICSEARCH_VERSION ?= $(lastword $(VERSIONS))
ELASTICSEARCH_PLUGINS ?=

IMAGE_NAME ?= zerodowntime/elasticsearch
IMAGE_TAG  ?= ${ELASTICSEARCH_VERSION}

build: Dockerfile
	docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" \
		--build-arg "ELASTICSEARCH_VERSION=${ELASTICSEARCH_VERSION}" \
		--build-arg "ELASTICSEARCH_PLUGINS=${ELASTICSEARCH_PLUGINS}" \
		.

push: build
	docker push "${IMAGE_NAME}:${IMAGE_TAG}"

clean:
	docker image rm "${IMAGE_NAME}:${IMAGE_TAG}"

runit: build
	docker run -it --rm "${IMAGE_NAME}:${IMAGE_TAG}"

## Here be dragons.

push-all:
push-all:
	echo $(foreach VER, $(VERSIONS), $(MAKE) push-ver ELASTICSEARCH_VERSION=$(VER);)

push-ver:
	$(MAKE) push # vanilla
	$(MAKE) push ELASTICSEARCH_PLUGINS=repository-s3	IMAGE_TAG=${ELASTICSEARCH_VERSION}-s3
	$(MAKE) push ELASTICSEARCH_PLUGINS=repository-gcs IMAGE_TAG=${ELASTICSEARCH_VERSION}-gcs
