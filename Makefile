IMAGE_NAME 	:=	cirocosta/gitserver-http
SAMPLE_REPO	:=  ./example/repositories/sample-repo

all: image

.PHONY: image example test

test:
	./test.sh

image:
	docker build -t $(IMAGE_NAME) .

example: 
	docker-compose -f ./example/docker-compose.yml up

