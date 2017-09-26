# Package name
PACKAGE:=github.com/memes/hello-container

# Try to use a sane GOPATH for this build
export GOPATH=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

# Docker stuff
DOCKER_TAG:=memes/hello-container:1.0.0

# When on Windows, force shell to be cmd
ifeq ($(OS),Windows_NT)
SHELL=cmd.exe
endif

# Bust tha' docker cache
ifeq ($(findstring sh,$(SHELL)),sh)
BUST_A_CACHE:=$(shell date +%s)
else
BUST_A_CACHE:=$(shell echo %date: =%%time%)
endif

# If main.go is not present, pull the sources from git
src/$(PACKAGE)/main.go:
	go get $(PACKAGE)

build:
	go test -v $(PACKAGE)/...
	go install $(PACKAGE)

clean:
	go clean -i -r $(PACKAGE)

container: Dockerfile
	docker build --rm -t $(DOCKER_TAG) --build-arg BUST_A_CACHE='$(BUST_A_CACHE)' .

push: container
	docker push $(DOCKER_TAG)

realclean: clean
	-docker rmi $(DOCKER_TAG)

.PHONY: realclean push container clean build
