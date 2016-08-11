.PHONY: build run docker docker.run publish

NAME = marathon-scaler
REGISTRY = 951625648013.dkr.ecr.us-east-1.amazonaws.com
DIR := $(shell pwd)

# Get latest git tag, and extract the version number part out of it (e.g. 0.1.6). Then add
# one to the last number to produce a new version number. Any version number that has at least
# to parts (0.1) works.
# git for-each-ref --count=1 --sort="-*creatordate" --format="%(refname)" refs/tags | sort
#
GIT_TAG := $(shell git for-each-ref --format='%(*committerdate:raw)%(committerdate:raw) %(refname) %(*objectname) %(objectname)' refs/tags | sort -n | awk '{ print $$4, $$3; }' | tail -1)
GIT_TAG_VERSION := $(shell python -c "print '%s' % ('$(GIT_TAG)'.split('/')[-1])")
VER_LEFT := $(shell python -c "print '%s.' % ('$(GIT_TAG_VERSION)'.rsplit('.', 1)[0])")
VER_RIGHT := $(shell python -c "print '%d' % (int('$(GIT_TAG_VERSION)'.rsplit('.', 1)[1]) + 1)")
PUBLISH_VERSION := $(VER_LEFT)$(VER_RIGHT)

default: run

run: 
	chmod +x ./scale.sh
	./scale.sh http://localhost:8999/mesos http://localhost:8999/service/marathon logspout,bar

docker:
	docker build -t $(NAME):latest .

# Build and run the container. This is mainly for local development time
# container testing. 
docker.run: docker
	docker run $(NAME):latest http://localhost:8999/mesos http://localhost:8999/service/marathon logspout,bar

# Build the container, tag it with version information, and publish it to the Docker registry.
publish: docker
	@echo ""
	@echo "Tag the version to git repository and push to origin as that is the only place where version information is stored."
	git tag -a $(PUBLISH_VERSION) -m $(REGISTRY)/$(NAME):$(PUBLISH_VERSION)
	git push origin --tags

	@echo ""
	@echo "Deploying the newly built image to the container registry..."
	@echo "Refreshing AWS ECR credentials"
	$(shell aws ecr get-login)

	@echo ""
	@echo "Tagging image with 'latest' and '$(PUBLISH_VERSION)'"
	docker tag $(NAME):latest $(REGISTRY)/$(NAME):latest
	docker tag $(NAME):latest $(REGISTRY)/$(NAME):$(PUBLISH_VERSION)

	@echo ""
	@echo "Deploying to $(REGISTRY)"
	docker push $(REGISTRY)/$(NAME):latest
	docker push $(REGISTRY)/$(NAME):$(PUBLISH_VERSION)


