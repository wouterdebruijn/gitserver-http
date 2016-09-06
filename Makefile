IMAGE_NAME 	:=	cirocosta/gitserver-http
SAMPLE_REPO	:=  ./example/repositories/sample-repo

all: image

.PHONY: image example example-no-init test

test:
	./test.sh

image:
	docker build -t $(IMAGE_NAME) .

example-no-init: 
	docker-compose -f ./example/docker-compose.no-init.yml up

example: 
	docker-compose -f ./example/docker-compose.yml up

