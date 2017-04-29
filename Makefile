LOCALVERSION ?=
export VERSION ?= dev
export DATE ?= $(VERSION)
export RELEASE ?= 1
LINUX_BRANCH ?= my-hacks-1.2
BOOT_TOOLS_BRANCH ?= master

all: xenial-pinebook

linux/.git:
	git clone --depth=1 --branch=$(LINUX_BRANCH) --single-branch \
		https://github.com/ayufan-pine64/linux-pine64.git linux

linux/.config: linux/.git
	make -C linux ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" LOCALVERSION=$(LOCALVERSION) clean CONFIG_ARCH_SUN50IW1P1=y
	make -C linux ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" sun50iw1p1smp_linux_defconfig
	touch linux/.config

linux/arch/arm64/boot/Image: linux/.config
	make -C linux ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" -j4 LOCALVERSION=$(LOCALVERSION) modules
	make -C linux M=modules/gpu/mali400/kernel_mode/driver/src/devicedrv/mali \
		ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" \
		CONFIG_MALI400=m CONFIG_MALI450=y CONFIG_MALI400_PROFILING=y \
		CONFIG_MALI_DMA_BUF_MAP_ON_ATTACH=y CONFIG_MALI_DT=y \
		EXTRA_DEFINES="-DCONFIG_MALI400=1 -DCONFIG_MALI450=1 -DCONFIG_MALI400_PROFILING=1 -DCONFIG_MALI_DMA_BUF_MAP_ON_ATTACH -DCONFIG_MALI_DT"
	make -C linux ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" -j4 LOCALVERSION=$(LOCALVERSION) Image

busybox/.git:
	git clone --depth 1 --branch 1_24_stable --single-branch git://git.busybox.net/busybox busybox

busybox: busybox/.git
	cp -u kernel/pine64_config_busybox busybox/.config
	make -C busybox ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" -j4 oldconfig

busybox/busybox: busybox
	make -C busybox ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" -j4

kernel/initrd.gz: busybox/busybox
	cd kernel/ && ./make_initrd.sh

boot-tools/.git:
	git clone --single-branch --depth=1 --branch=$(BOOT_TOOLS_BRANCH) https://github.com/ayufan-pine64/boot-tools

boot-tools: boot-tools/.git

linux-pine64-$(VERSION).tar.xz: linux/arch/arm64/boot/Image boot-tools kernel/initrd.gz
	cd kernel && bash ./make_kernel_tarball.sh $(shell dirname $(shell readlink -f "$@"))

kernel-tarball: linux-pine64-$(VERSION).tar.xz

simple-image-pinebook.img: linux-pine64-$(VERSION).tar.xz boot-tools
	cd simpleimage && \
		export boot0=../boot-tools/build/boot0_pinebook.bin && \
		export uboot=../boot-tools/build/u-boot-sun50iw1p1-secure-with-pinebook-dtb.bin && \
		bash ./make_simpleimage.sh $(shell readlink -f "$@") 100 $(shell readlink -f linux-pine64-$(VERSION).tar.xz)

%.img.xz: %.img
	xz -3 $<

xenial-pinebook-bspkernel-$(DATE)-$(RELEASE).img: simple-image-pinebook.img.xz linux-pine64-$(VERSION).tar.xz boot-tools
	sudo MODEL=pinebook DATE=$(DATE) bash \
		./build-pine64-image.sh \
		$(shell readlink -f simple-image-pinebook.img.xz) \
		$(shell readlink -f linux-pine64-$(VERSION).tar.xz) \
		xenial \
		$(RELEASE)

xenial-pinebook: xenial-pinebook-bspkernel-$(DATE)-$(RELEASE).img.xz
