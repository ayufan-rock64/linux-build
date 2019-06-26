export VERSION ?= $(shell cat VERSION)
export KERNEL_VERSION ?= $(shell cat KERNEL_VERSION)
export UBOOT_VERSION ?= $(shell cat UBOOT_VERSION)
export RELEASE_NAME ?= $(VERSION)~dev
export RELEASE ?= 1
export BOOT_TOOLS_BRANCH ?= master
export KERNEL_DIR ?= kernel
export UBOOT_DIR ?= u-boot

BUILD_SYSTEMS := bionic xenial jessie stretch
BUILD_VARIANTS := minimal mate lxde i3 openmediavault containers
BUILD_ARCHS := armhf arm64
BUILD_MODELS := rock64 rockpro64 pinebookpro rockpi4b

BOARD_TARGET ?= rock64

ifeq (,$(filter $(BUILD_MODELS), $(BOARD_TARGET)))
$(error Unsupported BOARD_TARGET)
endif

IMAGE_SUFFIX := $(RELEASE_NAME)-$(RELEASE)

all: linux-variants linux-virtual

ifneq (,$(CI))
include Makefile.versions.mk
endif

include Makefile.package.mk
include Makefile.system.mk
include Makefile.variants.mk
include Makefile.dev.mk
