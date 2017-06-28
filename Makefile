export RELEASE_NAME ?= 0.1~dev
export RELEASE ?= 1
export BOOT_TOOLS_BRANCH ?= master

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

IMAGE_SUFFIX := $(RELEASE_NAME)-$(RELEASE)

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
		--depends gdisk \
        --depends parted \
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

BUILD_SYSTEMS := xenial zesty jessie stretch
BUILD_VARIANTS := minimal mate i3 openmediavault
BUILD_ARCHS := armhf arm64
BUILD_MODELS := rock64

%-system.img: $(PACKAGES)
	sudo bash rootfs/build-system-image.sh \
		"$(shell readlink -f $@)" \
		"$(filter $(BUILD_SYSTEMS), $(subst -, ,$@))" \
		"$(filter $(BUILD_VARIANTS), $(subst -, ,$@))" \
		"$(filter $(BUILD_ARCHS), $(subst -, ,$@))" \
		"$(filter $(BUILD_MODELS), $(subst -, ,$@))" \
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
xenial-minimal-rock64: xenial-minimal-rock64-$(IMAGE_SUFFIX)-armhf.img.xz xenial-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: xenial-mate-rock64
xenial-mate-rock64: xenial-mate-rock64-$(IMAGE_SUFFIX)-armhf.img.xz

.PHONY: xenial-i3-rock64
xenial-i3-rock64: xenial-i3-rock64-$(IMAGE_SUFFIX)-armhf.img.xz

.PHONY: jessie-minimal-rock64
jessie-minimal-rock64: jessie-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: jessie-openmediavault-rock64
jessie-openmediavault-rock64: jessie-openmediavault-rock64-$(IMAGE_SUFFIX)-armhf.img.xz

.PHONY: stretch-minimal-rock64
stretch-minimal-rock64: stretch-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: xenial-rock64
xenial-rock64: xenial-minimal-rock64 xenial-mate-rock64 xenial-i3-rock64

.PHONY: stretch-rock64
stretch-rock64: stretch-minimal-rock64

.PHONY: jessie-rock64
jessie-rock64: jessie-minimal-rock64 jessie-openmediavault-rock64

.PHONY: linux-rock64
linux-rock64: xenial-rock64 stretch-rock64 jessie-rock64
