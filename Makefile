IMAGE_NAMES := lsp check
BUILD_TARGETS := $(patsubst %,build-%,$(IMAGE_NAMES))
PUSH_TARGETS := $(patsubst %,push-%,$(IMAGE_NAMES))

VERSION=0.0.1

IMAGE_NAME=platformos/platformos

build: $(BUILD_TARGETS)
build-%:
	docker build -t ${IMAGE_NAME}-$*:${VERSION} -f docker/$*.Dockerfile .
	docker tag ${IMAGE_NAME}-$*:${VERSION} ${IMAGE_NAME}-$*:latest

push: $(PUSH_TARGETS)
push-%:
	docker push ${IMAGE_NAME}-$*:${VERSION}
	docker push ${IMAGE_NAME}-$*:latest

