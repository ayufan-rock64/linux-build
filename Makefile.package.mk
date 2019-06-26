LATEST_UBOOT_VERSION ?= $(shell scripts/get-package-version linux-u-boot tag $(UBOOT_VERSION))
LATEST_KERNEL_VERSION ?= $(shell scripts/get-package-version linux-kernel tag_with_sha $(KERNEL_VERSION))
LATEST_PACKAGE_VERSION ?= $(shell scripts/get-package-version linux-package tag $(VERSION))

PACKAGES += linux-$(BOARD_TARGET)-$(RELEASE_NAME)_arm64.deb

generate-latest:
	@echo LATEST_UBOOT_VERSION=$(LATEST_UBOOT_VERSION)
	@echo LATEST_KERNEL_VERSION=$(LATEST_KERNEL_VERSION)
	@echo LATEST_PACKAGE_VERSION=$(LATEST_PACKAGE_VERSION)

linux-$(BOARD_TARGET)-$(RELEASE_NAME)_arm64.deb:
	fpm -s empty -t deb -n linux-$(BOARD_TARGET)-$(VERSION) -v $(RELEASE_NAME) \
		-p $@ \
		--deb-priority optional --category admin \
		--depends "board-package-$(BOARD_TARGET)-$(LATEST_PACKAGE_VERSION)" \
		--depends "u-boot-rockchip-$(BOARD_TARGET)-$(LATEST_UBOOT_VERSION)" \
		--depends "linux-image-$(LATEST_KERNEL_VERSION)" \
		--depends "linux-headers-$(LATEST_KERNEL_VERSION)" \
		--deb-field "Provides: linux-board-virtual" \
		--deb-field "Replaces: linux-board-virtual" \
		--deb-field "Conflicts: linux-board-virtual" \
		--force \
		--url https://gitlab.com/ayufan-rock64/linux-build \
		--description "Rock64 Linux virtual package: depends on kernel and compatibility package" \
		-m "Kamil Trzciński <ayufan@ayufan.eu>" \
		--license "MIT" \
		--vendor "Kamil Trzciński" \
		-a arm64

linux-virtual: linux-$(BOARD_TARGET)-$(RELEASE_NAME)_arm64.deb
