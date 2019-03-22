LATEST_UBOOT_VERSION ?= $(shell curl --fail -s https://api.github.com/repos/ayufan-rock64/linux-u-boot/releases | jq -r ".[0].tag_name")
LATEST_KERNEL_VERSION ?= $(shell curl --fail -s https://api.github.com/repos/ayufan-rock64/linux-kernel/releases | jq -r '.[0] | (.tag_name + "-g" + (.target_commitish | .[0:12]))')
LATEST_PACKAGE_VERSION ?= $(shell curl --fail -s https://api.github.com/repos/ayufan-rock64/linux-package/releases | jq -r ".[].tag_name" | grep -m 1 "^$(VERSION)-")

PACKAGES += linux-$(BOARD_TARGET)-$(RELEASE_NAME)_arm64.deb

generate-versions:
	@echo LATEST_UBOOT_VERSION=$(LATEST_UBOOT_VERSION)
	@echo LATEST_KERNEL_VERSION=$(LATEST_KERNEL_VERSION)
	@echo LATEST_PACKAGE_VERSION=$(LATEST_PACKAGE_VERSION)

linux-$(BOARD_TARGET)-$(RELEASE_NAME)_arm64.deb:
	fpm -s empty -t deb -n linux-$(BOARD_TARGET) -v $(RELEASE_NAME) \
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
