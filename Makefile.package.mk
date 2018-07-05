LATEST_UBOOT_VERSION ?= $(shell curl --fail -s https://api.github.com/repos/ayufan-rock64/linux-u-boot/releases | jq -r ".[0].tag_name")
LATEST_KERNEL_VERSION ?= $(shell curl --fail -s https://api.github.com/repos/ayufan-rock64/linux-kernel/releases | jq -r '.[0] | (.tag_name + "-g" + (.target_commitish | .[0:12]))')

PACKAGES += linux-$(BOARD_TARGET)-package-$(RELEASE_NAME)_all.deb
PACKAGES += linux-$(BOARD_TARGET)-$(RELEASE_NAME)_arm64.deb

linux-$(BOARD_TARGET)-$(RELEASE_NAME)_arm64.deb: $(PACKAGES)
	fpm -s empty -t deb -n linux-$(BOARD_TARGET) -v $(RELEASE_NAME) \
		-p $@ \
		--deb-priority optional --category admin \
		--depends "linux-$(BOARD_TARGET)-package (= $(RELEASE_NAME))" \
		--depends "u-boot-rockchip-$(BOARD_TARGET) (= $(LATEST_UBOOT_VERSION))" \
		--depends "linux-image-$(LATEST_KERNEL_VERSION)" \
		--depends "linux-headers-$(LATEST_KERNEL_VERSION)" \
		--force \
		--url https://gitlab.com/ayufan-rock64/linux-build \
		--description "Rock64 Linux virtual package: depends on kernel and compatibility package" \
		-m "Kamil Trzciński <ayufan@ayufan.eu>" \
		--license "MIT" \
		--vendor "Kamil Trzciński" \
		-a arm64

linux-$(BOARD_TARGET)-package-$(RELEASE_NAME)_all.deb: package
	chmod -R go-w $<
	fpm -s dir -t deb -n linux-$(BOARD_TARGET)-package -v $(RELEASE_NAME) \
		-p $@ \
		--deb-priority optional --category admin \
		--force \
		--depends figlet \
		--depends cron \
		--depends gdisk \
		--depends parted \
		--depends device-tree-compiler \
		--depends linux-base \
		--deb-compression bzip2 \
		--deb-field "Multi-Arch: foreign" \
		--after-install package/scripts/postinst.deb \
		--before-remove package/scripts/prerm.deb \
		--url https://gitlab.com/ayufan-rock64/linux-build \
		--description "Rock64 Linux support package" \
		--config-files /boot/efi/extlinux/ \
		-m "Kamil Trzciński <ayufan@ayufan.eu>" \
		--license "MIT" \
		--vendor "Kamil Trzciński" \
		-a all \
		package/root/=/ \
		package/root-$(BOARD_TARGET)/=/

linux-$(BOARD_TARGET)-package-$(RELEASE_NAME)_all.rpm: package
	chmod -R go-w $<
	fpm -s dir -t rpm -n linux-$(BOARD_TARGET)-package -v $(RELEASE_NAME) \
		-p $@ \
		--force \
		--depends figlet \
		--depends cron \
		--depends gdisk \
		--depends parted \
		--after-install package/scripts/postinst.deb \
		--before-remove package/scripts/prerm.deb \
		--url https://gitlab.com/ayufan-rock64/linux-build \
		--description "Rock64 Linux support package" \
		--config-files /boot/efi/extlinux/ \
		-m "Kamil Trzciński <ayufan@ayufan.eu>" \
		--license "MIT" \
		--vendor "Kamil Trzciński" \
		-a all \
		package/root/=/

.PHONY: linux-package		# compile linux compatibility package
linux-package: linux-$(BOARD_TARGET)-package-$(RELEASE_NAME)_all.deb linux-$(BOARD_TARGET)-package-$(RELEASE_NAME)_all.rpm

.PHONY: linux-virtual		# compile linux package tying compatiblity package and kernel package
linux-virtual: linux-$(BOARD_TARGET)-$(RELEASE_NAME)_arm64.deb
