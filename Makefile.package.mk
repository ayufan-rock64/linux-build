LATEST_UBOOT_VERSION ?= $(shell scripts/get-package-version linux-mainline-u-boot tag_iid $(UBOOT_VERSION))
LATEST_KERNEL_VERSION ?= $(shell scripts/get-package-version linux-mainline-kernel tag_with_sha $(KERNEL_VERSION))
LATEST_ROOTFS_VERSION ?= $(shell scripts/get-package-version linux-rootfs tag_version $(ROOTFS_VERSION))
LATEST_PACKAGE_VERSION ?= $(shell scripts/get-package-version linux-package tag_iid $(VERSION))

PACKAGES += linux-$(BOARD_TARGET)-$(RELEASE_NAME)-mainline_arm64.deb

generate-latest:
	@echo LATEST_UBOOT_VERSION=$(LATEST_UBOOT_VERSION)
	@echo LATEST_KERNEL_VERSION=$(LATEST_KERNEL_VERSION)
	@echo LATEST_ROOTFS_VERSION=$(LATEST_ROOTFS_VERSION)
	@echo LATEST_PACKAGE_VERSION=$(LATEST_PACKAGE_VERSION)

store-latest:
	git checkout Makefile.latest.mk
	make -s generate-latest | tee Makefile.latest.mk

ifeq (,$(CI))
.PHONY: linux-$(BOARD_TARGET)-$(RELEASE_NAME)-mainline_arm64.deb
endif

linux-$(BOARD_TARGET)-$(RELEASE_NAME)-mainline_arm64.deb: Makefile.latest.mk
	fpm -s empty -t deb -n linux-$(BOARD_TARGET)-$(VERSION)-mainline -v $(RELEASE_NAME) \
		-p $@ \
		--deb-priority optional --category admin \
		--depends "board-package-$(BOARD_TARGET)-$(LATEST_PACKAGE_VERSION)" \
		--depends "u-boot-$(BOARD_TARGET)-$(LATEST_UBOOT_VERSION)" \
		--depends "linux-image-$(LATEST_KERNEL_VERSION)" \
		--depends "linux-headers-$(LATEST_KERNEL_VERSION)" \
		--deb-field "Provides: linux-board-mainline-virtual" \
		--deb-field "Provides: linux-board-mainline-virtual" \
		--deb-field "Replaces: linux-board-mainline-virtual" \
		--deb-field "Conflicts: linux-board-virtual" \
		--force \
		--url https://gitlab.com/ayufan-rock64/linux-build \
		--description "Rock64 Linux virtual package: depends on kernel and compatibility package" \
		-m "Kamil Trzciński <ayufan@ayufan.eu>" \
		--license "MIT" \
		--vendor "Kamil Trzciński" \
		-a arm64

linux-virtual: linux-$(BOARD_TARGET)-$(RELEASE_NAME)-mainline_arm64.deb
