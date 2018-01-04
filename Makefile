export RELEASE_NAME ?= 0.1~dev
export RELEASE ?= 1
export BOOT_TOOLS_BRANCH ?= master
export KERNEL_DIR ?= kernel
export UBOOT_DIR ?= u-boot

BUILD_SYSTEMS := bionic xenial jessie stretch
BUILD_VARIANTS := minimal mate i3 openmediavault
BUILD_ARCHS := armhf arm64
BUILD_MODELS := rock64

KERNEL_EXTRAVERSION ?= -rockchip-ayufan-$(RELEASE)
KERNEL_DEFCONFIG ?= rockchip_linux_defconfig

UBOOT_DEFCONFIG ?= rock64-rk3328_defconfig

REMOTE_HOST ?= rock64.home

IMAGE_SUFFIX := $(RELEASE_NAME)-$(RELEASE)

all: linux-rock64

include Makefile.atf.mk
include Makefile.uboot.mk
include Makefile.package.mk
include Makefile.kernel.mk
include Makefile.system.mk
include Makefile.variants.mk
include Makefile.loader.mk
include Makefile.dev.mk

