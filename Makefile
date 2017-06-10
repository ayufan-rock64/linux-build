export RELEASE_NAME ?= 0.1~dev
export RELEASE ?= 1
export BOOT_TOOLS_BRANCH ?= master

all: linux-rock64

package/rtk_bt/.git:
	git clone --single-branch --depth=1 https://github.com/NextThingCo/rtl8723ds_bt package/rtk_bt

package/rtk_bt/rtk_hciattach/rtk_hciattach: package/rtk_bt/.git
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
		-a arm64 \
		package/root/=/ \
		package/rtk_bt/rtk_hciattach/rtk_hciattach=/usr/local/sbin/rtk_hciattach

%.tar.xz: %.tar
	pxz -f -3 $<

%.img.xz: %.img
	pxz -f -3 $<

xenial-minimal-rock64-$(RELEASE_NAME)-$(RELEASE).img: linux-rock64-package-$(RELEASE_NAME).deb
	sudo bash ./build-rock64-image.sh \
		$(shell readlink -f $@) \
		$(shell readlink -f $<) \
		"" \
		$(shell readlink -f linux-rock64-package-$(RELEASE_NAME).deb) \
		xenial \
		rock64 \
		minimal

xenial-minimal-rock64-$(RELEASE_NAME)-$(RELEASE).img: linux-rock64-package-$(RELEASE_NAME).deb
	sudo bash ./build-rock64-image.sh \
		$(shell readlink -f $@) \
		$(shell readlink -f $<) \
		$(shell readlink -f linux-rock64-$(RELEASE_NAME).tar.xz) \
		$(shell readlink -f linux-rock64-package-$(RELEASE_NAME).deb) \
		xenial \
		pinebook \
		minimal

xenial-mate-rock64-$(RELEASE_NAME)-$(RELEASE).img: linux-rock64-package-$(RELEASE_NAME).deb
	sudo bash ./build-rock64-image.sh \
		$(shell readlink -f $@) \
		$(shell readlink -f $<) \
		"" \
		$(shell readlink -f linux-rock64-package-$(RELEASE_NAME).deb) \
		xenial \
		pinebook \
		mate \
		7300

xenial-i3-rock64-$(RELEASE_NAME)-$(RELEASE).img: linux-rock64-package-$(RELEASE_NAME).deb
	sudo bash ./build-rock64-image.sh \
		$(shell readlink -f $@) \
		$(shell readlink -f $<) \
		"" \
		$(shell readlink -f linux-rock64-package-$(RELEASE_NAME).deb) \
		xenial \
		pinebook \
		i3

stretch-i3-rock64-$(RELEASE_NAME)-$(RELEASE).img: linux-rock64-package-$(RELEASE_NAME).deb
	sudo bash ./build-rock64-image.sh \
		$(shell readlink -f $@) \
		$(shell readlink -f $<) \
		"" \
		$(shell readlink -f linux-rock64-package-$(RELEASE_NAME).deb) \
		stretch \
		pinebook \
		i3

.PHONY: linux-package
linux-package: linux-rock64-package-$(RELEASE_NAME).deb

.PHONY: xenial-minimal-pinebook
xenial-minimal-rock64: xenial-minimal-pinebook-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: xenial-mate-pinebook
xenial-mate-rock64: xenial-mate-pinebook-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: xenial-i3-pinebook
xenial-i3-rock64: xenial-i3-pinebook-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: stretch-i3-pinebook
stretch-i3-rock64: stretch-i3-pinebook-$(RELEASE_NAME)-$(RELEASE).img.xz

.PHONY: xenial-pinebook
xenial-rock64: xenial-minimal-rock64 xenial-mate-rock64 xenial-i3-rock64

.PHONY: linux-rock64
linux-rock64: xenial-rock64
