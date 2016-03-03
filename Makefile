#
# A Simple Makefile that can build docker images in a "dependant" manner
# ramon@thebuckland.com
#

DOCKER_IDENTITY_FILE = .docker-identity

# this makes a list of all the "docker directories" eg: image1 image2
docker_images := $(shell find . -maxdepth 2 -mindepth 2 -type f -name Dockerfile | xargs -L1 dirname | xargs -L1 basename )

# this makes a list of image1/Dockerfile image2/Docerfile
docker_files := $(docker_images:%=%/Dockerfile)

# this makes a list of image1/.docker-identity image2/.docker-identity
docker_identities := $(docker_files:%Dockerfile=%$(DOCKER_IDENTITY_FILE))

$(docker_images): $(docker_identities)

%/$(DOCKER_IDENTITY_FILE): %/Dockerfile
	@imagename=$(shell dirname $<) ; \
	imagever=$$(awk -F'"' 'BEGIN {ver="latest"} /build.publish.version/ {ver=$$2} END { print ver }' $$imagename/Dockerfile) ; \
	imageprefix=$$(awk -F'"' 'BEGIN {pref=""} /build.publish.username/ {pref=$$2 "/"} END { print pref }' $$imagename/Dockerfile) ; \
	dockertag=$${imageprefix}$${imagename}:$${imagever} ; \
	echo ::: Creating $${dockertag} ; \
	(cd $$imagename && docker build -t $$dockertag .) && \
	docker inspect -f '{{.Id}}' $${dockertag} > $$imagename/$(DOCKER_IDENTITY_FILE)

.PHONY: $(docker_images) clean all

all	: build

build	: $(docker_images)

clean:
	find . -name $(DOCKER_IDENTITY_FILE) | xargs cat | sed 's/sha256://g' | xargs docker rmi --force ; \
	find . -type f -name $(DOCKER_IDENTITY_FILE) -exec rm {} \;
