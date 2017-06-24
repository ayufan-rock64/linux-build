export RELEASE_NAME ?= 0.1~dev
export RELEASE ?= 1
export BOOT_TOOLS_BRANCH ?= master
export BUILD_ARCH ?= armhf

KERNEL_LOCALVERSION ?= -ayufan-$(RELEASE)
KERNEL_MAKE ?= make -C kernel \
	LOCALVERSION=$(KERNEL_LOCALVERSION) \
	KDEB_PKGVERSION=$(RELEASE_NAME) \
	ARCH=arm64 \
	CROSS_COMPILE="ccache aarch64-linux-gnu-"
KERNEL_RELEASE ?= $(shell $(KERNEL_MAKE) -s kernelversion)$(KERNEL_LOCALVERSION)

KERNEL_PACKAGE ?= linux-image-$(KERNEL_RELEASE)_$(RELEASE_NAME)_arm64.deb
KERNEL_HEADERS_PACKAGES ?= linux-headers-$(KERNEL_RELEASE)_$(RELEASE_NAME)_arm64.deb
PACKAGES := linux-rock64-package-$(RELEASE_NAME).deb $(KERNEL_PACKAGE) $(KERNEL_HEADERS_PACKAGES)

all: linux-rock64

info:
	echo version: $(KERNEL_VERSION)
	echo release: $(KERNEL_RELEASE)

linux-rock64-package-$(RELEASE_NAME).deb: package
	fpm -s dir -t deb -n linux-rock64-package -v $(RELEASE_NAME) \
		-p $@ \
		--deb-priority optional --category admin \
		--force \
		--deb-compression bzip2 \
		--after-install package/scripts/postinst.deb \
		--before-remove package/scripts/prerm.deb \
		--url https://gitlab.com/ayufan-rock64/linux-build \
		--description "Rock64 Linux support package" \
		--config-files /boot/extlinux/ \
		-m "Kamil Trzciński <ayufan@ayufan.eu>" \
		--license "MIT" \
		--vendor "Kamil Trzciński" \
		-a all \
		package/root/=/

%.tar.xz: %.tar
	pxz -f -3 $<

%.img.xz: %.img
	pxz -f -3 $<

xenial-minimal-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: $(PACKAGES)
	sudo bash rootfs/build-system-image.sh \
		$(shell readlink -f $@) \
		xenial \
		minimal \
		"${BUILD_ARCH}" \
		rock64 \
		1024 \
		$^

xenial-mate-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: $(PACKAGES)
	sudo bash rootfs/build-system-image.sh \
		$(shell readlink -f $@) \
		xenial \
		mate \
		"${BUILD_ARCH}" \
		rock64 \
		5120 \
		$^

xenial-i3-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: $(PACKAGES)
	sudo bash rootfs/build-system-image.sh \
		$(shell readlink -f $@) \
		xenial \
		i3 \
		"${BUILD_ARCH}" \
		rock64 \
		2048 \
		$^

stretch-i3-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: $(PACKAGES)
	sudo bash rootfs/build-system-image.sh \
		$(shell readlink -f $@) \
		stretch \
		i3 \
		"${BUILD_ARCH}" \
		rock64 \
		2048 \
		$^

out/u-boot/uboot.img: u-boot/configs/rock64-rk3328_defconfig
	build/mk-uboot.sh rk3328-rock64

%.img: %-system.img out/u-boot/uboot.img
	build/mk-image.sh -c rk3328 -t system -r "$<" -o "$@.tmp"
	mv "$@.tmp" "$@"

$(KERNEL_PACKAGE): kernel/arch/arm64/configs/rockchip_linux_defconfig
	echo -n > kernel/.scmversion
	$(KERNEL_MAKE) rockchip_linux_defconfig
	$(KERNEL_MAKE) bindeb-pkg -j$(shell nproc)

$(KERNEL_HEADERS_PACKAGES): $(KERNEL_PACKAGE)

.PHONY: kernelpkg
kernelpkg: $(KERNEL_PACKAGE) $(KERNEL_HEADERS_PACKAGES)

.PHONY: kernel
kernel: kernelpkg

.PHONY: u-boot
u-boot: out/u-boot/uboot.img

.PHONY: linux-package
linux-package: linux-rock64-package-$(RELEASE_NAME).deb

.PHONY: xenial-minimal-rock64
xenial-minimal-rock64: xenial-minimal-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH).img.xz

.PHONY: xenial-mate-rock64
xenial-mate-rock64: xenial-mate-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH).img.xz

.PHONY: xenial-i3-rock64
xenial-i3-rock64: xenial-i3-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH).img.xz

.PHONY: stretch-i3-rock64
stretch-i3-rock64: stretch-i3-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH).img.xz

.PHONY: xenial-rock64
xenial-rock64: xenial-minimal-rock64 xenial-mate-rock64 xenial-i3-rock64

.PHONY: linux-rock64
linux-rock64: xenial-rock64
