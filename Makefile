#DOCKER="docker"
DOCKER=sudo docker

DOCKER_IMAGE_NAME=zyxel-builder

all: build-image

build-image: build-docker-image build/image/build_NAS542.tar.gz build/image/patches build/image/build.sh
	$(DOCKER) run --rm -v $(PWD)/build/image:/build --network=none -u0:0 $(DOCKER_IMAGE_NAME) /build/build.sh

build-docker-image: build/docker/e2fsprogs-1.47.0.tar.xz build/docker/host.tar.gz build/docker/staging.tar.gz build/docker/tool.tar.gz build/docker/x-tools.tar.gz
	$(DOCKER) build -t $(DOCKER_IMAGE_NAME) -f Dockerfile build/docker

build/docker/e2fsprogs-1.47.0.tar.xz:
	mkdir -p build/docker
	rm -f build/docker/e2fsprogs-1.47.0.tar.xz.tmp
	wget -O build/docker/e2fsprogs-1.47.0.tar.xz.tmp https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.47.0/e2fsprogs-1.47.0.tar.xz
	echo "144af53f2bbd921cef6f8bea88bb9faddca865da3fbc657cc9b4d2001097d5db *build/docker/e2fsprogs-1.47.0.tar.xz.tmp" | sha256sum -c -
	mv build/docker/e2fsprogs-1.47.0.tar.xz.tmp build/docker/e2fsprogs-1.47.0.tar.xz

build/docker/host.tar.gz: vendor/host.tar.gz
	mkdir -p build/docker
	cp vendor/host.tar.gz build/docker/host.tar.gz

build/docker/staging.tar.gz: vendor/staging.tar.gz
	mkdir -p build/docker
	cp vendor/staging.tar.gz build/docker/staging.tar.gz

build/docker/tool.tar.gz: vendor/tool.tar.gz
	mkdir -p build/docker
	cp vendor/tool.tar.gz build/docker/tool.tar.gz

build/docker/x-tools.tar.gz: vendor/x-tools.tar.gz
	mkdir -p build/docker
	cp vendor/x-tools.tar.gz build/docker/x-tools.tar.gz

build/image/build_NAS542.tar.gz: vendor/build_NAS542.tar.gz
	mkdir -p build/image
	cp vendor/build_NAS542.tar.gz build/image/build_NAS542.tar.gz

build/image/patches: patches
	mkdir -p build/image
	cp -r patches build/image/patches

build/image/build.sh: build.sh
	mkdir -p build/image
	cp build.sh build/image/build.sh

.PHONY: all build-image build-docker-image check-vendor-sources clean

clean:
	rm -rf work
	$(DOCKER) rmi $(DOCKER_IMAGE_NAME)
