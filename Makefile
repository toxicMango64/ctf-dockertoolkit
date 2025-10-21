IMAGE_NAME=security-toolkit
TAG=latest
IMAGE=$(IMAGE_NAME):$(TAG)

.PHONY: all
all: build post-install

.PHONY: build
build:
	docker build -t $(IMAGE) .

.PHONY: run
run:
	docker run -it -v "$(shell pwd)":/workspace $(IMAGE)
	yes | sh ./install

.PHONY: post-install
post-install:
	yes | sh ./install

.PHONY: clean
clean:
	@echo "No clean step defined."
