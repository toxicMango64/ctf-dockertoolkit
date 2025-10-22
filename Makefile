IMAGE_NAME=security-toolkit
TAG=latest
IMAGE=$(IMAGE_NAME):$(TAG)

.PHONY: all
all: pre-install build run

.PHONY: pre-install
pre-install:
	git pull
	chmod +x ./install.sh
	yes | sh ./install.sh

.PHONY: build
build:
	docker build -t $(IMAGE) .

.PHONY: run
run:
	docker run -it -v "$(shell pwd)":/workspace $(IMAGE)
