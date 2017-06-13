export RELEASE_NAME ?= 0.1~dev
export RELEASE ?= 1
export BOOT_TOOLS_BRANCH ?= master
export BUILD_ARCH ?= armhf

ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: linux-rock64

package/rtk_bt/rtk_hciattach/rtk_hciattach:
	make -C package/rtk_bt/rtk_hciattach CC="ccache aarch64-linux-gnu-gcc"

linux-rock64-package-$(RELEASE_NAME).deb: package package/rtk_bt/rtk_hciattach/rtk_hciattach
	fpm -s dir -t deb -n linux-rock64-package -v $(RELEASE_NAME) \
		-p $@ \
		--deb-priority optional --category admin \
		--force \
		--deb-compression bzip2 \
		--after-install package/scripts/postinst.deb \
		--before-remove package/scripts/prerm.deb \
		--url https://gitlab.com/ayufan-rock64/linux-build \
		--description "GitLab Runner" \
		-m "Kamil Trzciński <ayufan@ayufan.eu>" \
		--license "MIT" \
		--vendor "Kamil Trzciński" \
		-a all \
		package/root/=/ \
		package/rtk_bt/rtk_hciattach/rtk_hciattach=/usr/local/sbin/rtk_hciattach

%.tar.xz: %.tar
	pxz -f -3 $<

%.img.xz: %.img
	pxz -f -3 $<

rootfs/linux-package.deb: linux-rock64-package-$(RELEASE_NAME).deb
	cp "$<" "$@"

%-system.img: rootfs/linux-package.deb rootfs/Dockerfile
	docker build \
		--tag=$(BUILD_SUITE)_$(BUILD_VARIANT)_$(BUILD_MODEL) \
		--build-arg BUILD_ARCH=$(BUILD_ARCH) \
		--build-arg BUILD_SUITE=$(BUILD_SUITE) \
		--build-arg BUILD_VARIANT=$(BUILD_VARIANT) \
		--build-arg BUILD_VARIANT_PACKAGES="$(BUILD_VARIANT_PACKAGES)" \
		--build-arg BUILD_ADDITIONAL_PACKAGES="$(BUILD_ADDITIONAL_PACKAGES)" \
		--build-arg BUILD_MODEL=$(BUILD_MODEL) \
		rootfs/
	touch $@.tmp
	docker run --rm -v $(ROOT_DIR):$(ROOT_DIR) $(BUILD_SUITE)_$(BUILD_VARIANT)_$(BUILD_MODEL) \
		$(shell readlink -f $@.tmp) /rootfs -l $(BUILD_SIZE)
	mv $@.tmp $@

xenial-minimal-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_SUITE=xenial
xenial-minimal-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_VARIANT=minimal
xenial-minimal-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_MODEL=rock64
xenial-minimal-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_SIZE=1G

xenial-i3-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_SUITE=xenial
xenial-i3-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_VARIANT=i3
xenial-i3-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_MODEL=rock64
xenial-i3-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_SIZE=2G
xenial-i3-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_ADDITIONAL_PACKAGES=aisleriot geany gnomine gnome-sudoku mplayer scratch smplayer smplayer-themes smtube chromium-browser
xenial-i3-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_VARIANT_PACKAGES=xserver-xorg-input-all xfonts-base slim rxvt-unicode-lite i3 i3status i3lock suckless-tools network-manager pulseaudio

xenial-mate-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_SUITE=xenial
xenial-mate-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_VARIANT=mate
xenial-mate-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_MODEL=rock64
xenial-mate-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_SIZE=6G
xenial-mate-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_ADDITIONAL_PACKAGES=aisleriot geany gnomine gnome-sudoku mplayer scratch smplayer smplayer-themes smtube chromium-browser
xenial-mate-rock64-$(RELEASE_NAME)-$(RELEASE)-$(BUILD_ARCH)-system.img: BUILD_VARIANT_PACKAGES=ubuntu-mate-core ubuntu-mate-desktop ubuntu-mate-lightdm-theme ubuntu-mate-wallpapers-xenial lightdm

out/kernel/Image out/kernel/rk3328-rock64.dtb: kernel/arch/arm64/configs/rockchip_linux_defconfig
	build/mk-kernel.sh rk3328-rock64

out/boot.img: out/kernel/Image out/kernel/rk3328-rock64.dtb
	build/mk-image.sh -c rk3328 -t boot

out/u-boot/uboot.img: u-boot/configs/rock64-rk3328_defconfig
	build/mk-uboot.sh rk3328-rock64

%.img: %-system.img
	build/mk-image.sh -c rk3328 -t system -r "$<" -o "$@.tmp"
	mv "$@.tmp" "$@"

.PHONY: kernel
kernel: out/boot.img

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
