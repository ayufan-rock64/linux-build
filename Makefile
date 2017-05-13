export RELEASE_NAME ?= 0.1~dev
export RELEASE ?= 1
export LINUX_BRANCH ?= my-hacks-1.2
export BOOT_TOOLS_BRANCH ?= master
LINUX_LOCALVERSION ?= -ayufan-$(RELEASE)

all: linux-pinebook linux-pine64

linux/.git:
	git clone --depth=1 --branch=$(LINUX_BRANCH) --single-branch \
		https://github.com/ayufan-pine64/linux-pine64.git linux

linux/.config: linux/.git
	make -C linux ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" clean CONFIG_ARCH_SUN50IW1P1=y
	make -C linux ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" sun50iw1p1smp_linux_defconfig
	touch linux/.config

linux/arch/arm64/boot/Image: linux/.config
	make -C linux ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" -j4 LOCALVERSION=$(LINUX_LOCALVERSION) Image
	make -C linux ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" -j4 LOCALVERSION=$(LINUX_LOCALVERSION) modules
	make -C linux LOCALVERSION=$(LINUX_LOCALVERSION) M=modules/gpu/mali400/kernel_mode/driver/src/devicedrv/mali \
		ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" \
		CONFIG_MALI400=m CONFIG_MALI450=y CONFIG_MALI400_PROFILING=y \
		CONFIG_MALI_DMA_BUF_MAP_ON_ATTACH=y CONFIG_MALI_DT=y \
		EXTRA_DEFINES="-DCONFIG_MALI400=1 -DCONFIG_MALI450=1 -DCONFIG_MALI400_PROFILING=1 -DCONFIG_MALI_DMA_BUF_MAP_ON_ATTACH -DCONFIG_MALI_DT"

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

linux-pine64-$(RELEASE_NAME).tar: linux/arch/arm64/boot/Image boot-tools kernel/initrd.gz
	cd kernel && \
		bash ./make_kernel_tarball.sh $(shell readlink -f "$@")

package/rtk_bt/.git:
	git clone --single-branch --depth=1 https://github.com/NextThingCo/rtl8723ds_bt package/rtk_bt

package/rtk_bt/rtk_hciattach/rtk_hciattach: package/rtk_bt/.git
	make -C package/rtk_bt/rtk_hciattach CC="ccache aarch64-linux-gnu-gcc"

linux-pine64-package-$(RELEASE_NAME).deb: package package/rtk_bt/rtk_hciattach/rtk_hciattach
	fpm -s dir -t deb -n linux-pine64-package -v $(RELEASE_NAME) \
		-p $@ \
		--deb-priority optional --category admin \
		--force \
		--deb-compression bzip2 \
		--after-install package/scripts/postinst.deb \
		--before-remove package/scripts/prerm.deb \
		--url https://gitlab.com/ayufan-pine64/linux-build \
		--description "GitLab Runner" \
		-m "Kamil Trzciński <ayufan@ayufan.eu>" \
		--license "MIT" \
		--vendor "Kamil Trzciński" \
		-a arm64 \
		package/root/=/ \
		package/rtk_bt/rtk_hciattach/rtk_hciattach=/usr/local/sbin/rtk_hciattach

%.tar.xz: %.tar
	pxz -f -3 $<

%.img.xz: %.img
	pxz -f -3 $<

boot-tools/boot/pine64/boot0-pine64-%.bin: boot-tools
boot-tools/boot/pine64/u-boot-pine64-%.bin: boot-tools

simple-image-%-$(RELEASE_NAME).img: boot-tools/boot/pine64/boot0-pine64-%.bin boot-tools/boot/pine64/u-boot-pine64-%.bin \
	linux-pine64-$(RELEASE_NAME).tar.xz
	cd simpleimage && \
		export boot0=$(word 1,$^) && \
		export uboot=$(word 2,$^) && \
		bash ./make_simpleimage.sh $(shell readlink -f "$@") 100 $(shell readlink -f linux-pine64-$(RELEASE_NAME).tar.xz)

xenial-minimal-pine64-bspkernel-$(RELEASE_NAME)-$(RELEASE).img: simple-image-plus-$(RELEASE_NAME).img.xz linux-pine64-$(RELEASE_NAME).tar.xz linux-pine64-package-$(RELEASE_NAME).deb boot-tools
	sudo bash ./build-pine64-image.sh \
		$(shell readlink -f $@) \
		$(shell readlink -f $<) \
		$(shell readlink -f linux-pine64-$(RELEASE_NAME).tar.xz) \
		$(shell readlink -f linux-pine64-package-$(RELEASE_NAME).deb) \
		xenial \
		pine64 \
		minimal

xenial-minimal-pinebook-bspkernel-$(RELEASE_NAME)-$(RELEASE).img: simple-image-pinebook-$(RELEASE_NAME).img.xz linux-pine64-$(RELEASE_NAME).tar.xz linux-pine64-package-$(RELEASE_NAME).deb boot-tools
	sudo bash ./build-pine64-image.sh \
		$(shell readlink -f $@) \
		$(shell readlink -f $<) \
		$(shell readlink -f linux-pine64-$(RELEASE_NAME).tar.xz) \
		$(shell readlink -f linux-pine64-package-$(RELEASE_NAME).deb) \
		xenial \
		pinebook \
		minimal

xenial-mate-pinebook-bspkernel-$(RELEASE_NAME)-$(RELEASE).img: simple-image-pinebook-$(RELEASE_NAME).img.xz linux-pine64-$(RELEASE_NAME).tar.xz linux-pine64-package-$(RELEASE_NAME).deb boot-tools
	sudo bash ./build-pine64-image.sh \
		$(shell readlink -f $@) \
		$(shell readlink -f $<) \
		$(shell readlink -f linux-pine64-$(RELEASE_NAME).tar.xz) \
		$(shell readlink -f linux-pine64-package-$(RELEASE_NAME).deb) \
		xenial \
		pinebook \
		mate \
		7300

xenial-i3-pinebook-bspkernel-$(RELEASE_NAME)-$(RELEASE).img: simple-image-pinebook-$(RELEASE_NAME).img.xz linux-pine64-$(RELEASE_NAME).tar.xz linux-pine64-package-$(RELEASE_NAME).deb boot-tools
	sudo bash ./build-pine64-image.sh \
		$(shell readlink -f $@) \
		$(shell readlink -f $<) \
		$(shell readlink -f linux-pine64-$(RELEASE_NAME).tar.xz) \
		$(shell readlink -f linux-pine64-package-$(RELEASE_NAME).deb) \
		xenial \
		pinebook \
		i3

stretch-i3-pinebook-bspkernel-$(RELEASE_NAME)-$(RELEASE).img: simple-image-pinebook-$(RELEASE_NAME).img.xz linux-pine64-$(RELEASE_NAME).tar.xz linux-pine64-package-$(RELEASE_NAME).deb boot-tools
	sudo bash ./build-pine64-image.sh \
		$(shell readlink -f $@) \
		$(shell readlink -f $<) \
		$(shell readlink -f linux-pine64-$(RELEASE_NAME).tar.xz) \
		$(shell readlink -f linux-pine64-package-$(RELEASE_NAME).deb) \
		stretch \
		pinebook \
		i3

.PHONY: kernel-tarball
kernel-tarball: linux-pine64-$(RELEASE_NAME).tar.xz

.PHONY: linux-package
linux-package: linux-pine64-package-$(RELEASE_NAME).deb

.PHONY: simple-image-pinebook-$(RELEASE_NAME).img
simple-image-pinebook: simple-image-pinebook-$(RELEASE_NAME).img

.PHONY: xenial-minimal-pinebook
xenial-minimal-pinebook: xenial-minimal-pinebook-bspkernel-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: xenial-mate-pinebook
xenial-mate-pinebook: xenial-mate-pinebook-bspkernel-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: xenial-i3-pinebook
xenial-i3-pinebook: xenial-i3-pinebook-bspkernel-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: stretch-i3-pinebook
stretch-i3-pinebook: stretch-i3-pinebook-bspkernel-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: xenial-pinebook
xenial-pinebook: xenial-minimal-pinebook xenial-mate-pinebook xenial-i3-pinebook

.PHONY: linux-pinebook
linux-pinebook: xenial-minimal-pinebook xenial-mate-pinebook xenial-i3-pinebook

.PHONY: xenial-minimal-pine64
 xenial-minimal-pine64: xenial-minimal-pine64-bspkernel-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: linux-pine64
linux-pine64: xenial-minimal-pine64
