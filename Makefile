IMAGE_NAME 	:=	cirocosta/gitserver-http
SAMPLE_REPO	:=  ./example/repositories/sample-repo

all: image

.PHONY: image example

image:
	docker build -t $(IMAGE_NAME) .

example: 
	cd ./example && docker-compose up


