export RELEASE_NAME ?= 0.1~dev
export RELEASE ?= 1
export BOOT_TOOLS_BRANCH ?= master
export KERNEL_DIR ?= kernel
export UBOOT_DIR ?= u-boot

BUILD_SYSTEMS := bionic xenial jessie stretch
BUILD_VARIANTS := minimal mate lxde i3 openmediavault containers
BUILD_ARCHS := armhf arm64
BUILD_MODELS := rock64 rockpro64

ifeq (,$(filter $(BUILD_MODELS), $(BOARD_TARGET)))
$(error Unsupported BOARD_TARGET)
endif

BOARD_TARGET ?= rock64

IMAGE_SUFFIX := $(RELEASE_NAME)-$(RELEASE)

all: linux-$(BOARD_TARGET)

include Makefile.package.mk
include Makefile.system.mk
include Makefile.variants.mk
include Makefile.dev.mk
