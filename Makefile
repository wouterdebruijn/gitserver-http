IMAGE_NAME 	:=	cirocosta/gitserver-http
SAMPLE_REPO	:=  ./example/repositories/sample-repo

all: image

sample_repository: $(SAMPLE_REPO)/example-file.txt
	tar -xzf ./example/repo.tar.gz -C ./example/repositories


.PHONY: image example

image:
	docker build -t $(IMAGE_NAME) .

example: sample_repository
	cd ./example && docker-compose up


