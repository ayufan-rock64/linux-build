export RELEASE_NAME ?= 0.1~dev
export RELEASE ?= 1
export BOOT_TOOLS_BRANCH ?= master
export BUILD_ARCH ?= arm64

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
		-a $(BUILD_ARCH) \
		package/root/=/ \
		package/rtk_bt/rtk_hciattach/rtk_hciattach=/usr/local/sbin/rtk_hciattach

%.tar.xz: %.tar
	pxz -f -3 $<

%.img.xz: %.img
	pxz -f -3 $<

xenial-minimal-rock64-$(RELEASE_NAME)-$(RELEASE)-system.img: linux-rock64-package-$(RELEASE_NAME).deb
	sudo bash ./build-system-image.sh \
		$(shell readlink -f $@) \
		$(shell readlink -f $<) \
		"" \
		$(shell readlink -f linux-rock64-package-$(RELEASE_NAME).deb) \
		xenial \
		rock64 \
		minimal

xenial-minimal-rock64-$(RELEASE_NAME)-$(RELEASE)-system.img: linux-rock64-package-$(RELEASE_NAME).deb
	cd rootfs/ && sudo bash ./build-system-image.sh \
		$(shell readlink -f $@) \
		"" \
		"" \
		$(shell readlink -f linux-rock64-package-$(RELEASE_NAME).deb) \
		xenial \
		rock64 \
		minimal

xenial-mate-rock64-$(RELEASE_NAME)-$(RELEASE)-system.img: linux-rock64-package-$(RELEASE_NAME).deb
	cd rootfs/ && sudo bash ./build-system-image.sh \
		$(shell readlink -f $@) \
		"" \
		"" \
		$(shell readlink -f linux-rock64-package-$(RELEASE_NAME).deb) \
		xenial \
		rock64 \
		mate \
		7300

xenial-i3-rock64-$(RELEASE_NAME)-$(RELEASE)-system.img: linux-rock64-package-$(RELEASE_NAME).deb
	cd rootfs/ && sudo bash ./build-system-image.sh \
		$(shell readlink -f $@) \
		"" \
		"" \
		$(shell readlink -f linux-rock64-package-$(RELEASE_NAME).deb) \
		xenial \
		rock64 \
		i3

stretch-i3-rock64-$(RELEASE_NAME)-$(RELEASE)-system.img: linux-rock64-package-$(RELEASE_NAME).deb
	cd rootfs/ && sudo bash rootfs/build-system-image.sh \
		$(shell readlink -f $@) \
		"" \
		"" \
		$(shell readlink -f linux-rock64-package-$(RELEASE_NAME).deb) \
		stretch \
		rock64 \
		i3

out/kernel/Image out/kernel/rk3328-rock64.dtb: kernel/arch/arm64/configs/rockchip_linux_defconfig
	build/mk-kernel.sh rk3328-rock64

out/boot.img: out/kernel/Image out/kernel/rk3328-rock64.dtb
	build/mk-image.sh -c rk3328 -t boot

out/u-boot/uboot.img: u-boot/configs/rock64-rk3328_defconfig
	build/mk-uboot.sh rk3328-rock64

%.img: %-system.img
	build/mk-image.sh -c rk3328 -t system -r "$<" -o "$@"

.PHONY: kernel
kernel: out/boot.img

.PHONY: u-boot
u-boot: out/u-boot/uboot.img

.PHONY: linux-package
linux-package: linux-rock64-package-$(RELEASE_NAME).deb

.PHONY: xenial-minimal-rock64
xenial-minimal-rock64: xenial-minimal-rock64-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: xenial-mate-rock64
xenial-mate-rock64: xenial-mate-rock64-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: xenial-i3-rock64
xenial-i3-rock64: xenial-i3-rock64-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: stretch-i3-rock64
stretch-i3-rock64: stretch-i3-rock64-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: xenial-rock64
xenial-rock64: xenial-minimal-rock64 xenial-mate-rock64 xenial-i3-rock64

.PHONY: linux-rock64
linux-rock64: xenial-rock64
