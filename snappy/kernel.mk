include common.mk

all: build

clean:
	cd kernel; snapcraft clean

build:
	cd kernel; snapcraft --target-arch arm64 snap

.PHONY: build
