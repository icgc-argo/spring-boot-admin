DOCKERFILE_SERVER := Dockerfile
SOURCE_COMMIT := $$(git show | grep commit | tr -s ' ' | cut -d ' ' -f 2 | cut -c 1-8)
DOCKER_REPO := icgcargo/spring-boot-admin
DOCKER_CONTAINER_NAME := admin-server-$(SOURCE_COMMIT)
DOCKER_IMAGE_NAME := $(DOCKER_REPO):$(SOURCE_COMMIT)
API_HOST_PORT:= 8080

help:
	@grep '^[A-Za-z0-9_-]\+:.*' ./Makefile | sed 's/:.*//'

docker-server-clean:
	-docker kill $(DOCKER_CONTAINER_NAME)

docker-server-purge: docker-server-clean
	-docker rmi $(DOCKER_IMAGE_NAME)

docker-server-logs:
	docker logs $(DOCKER_CONTAINER_NAME)

docker-server-build: $(DOCKERFILE_SERVER)
	DOCKER_REPO=$(DOCKER_REPO) SOURCE_COMMIT=${SOURCE_COMMIT} API_HOST_PORT=${API_HOST_PORT} docker-compose build

docker-server-run: docker-server-build
	DOCKER_REPO=$(DOCKER_REPO) SOURCE_COMMIT=${SOURCE_COMMIT} API_HOST_PORT=${API_HOST_PORT} docker-compose up -d

