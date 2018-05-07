KERNEL_MAKE ?= make -C $(KERNEL_DIR) \
	EXTRAVERSION=$(KERNEL_EXTRAVERSION) \
	KDEB_PKGVERSION=$(RELEASE_NAME) \
	ARCH=arm64 \
	HOSTCC=aarch64-linux-gnu-gcc \
	CROSS_COMPILE="ccache aarch64-linux-gnu-"

ifneq (,$(wildcard $(KERNEL_DIR)))
KERNEL_RELEASE ?= $(shell $(KERNEL_MAKE) -s kernelversion)
else
$(warning "Missing $(KERNEL_DIR). Try to run `make sync`)
KERNEL_RELEASE ?= unknown
endif

KERNEL_PACKAGE ?= linux-image-$(KERNEL_RELEASE)_$(RELEASE_NAME)_arm64.deb
KERNEL_HEADERS_PACKAGES ?= linux-headers-$(KERNEL_RELEASE)_$(RELEASE_NAME)_arm64.deb

$(KERNEL_PACKAGE): $(KERNEL_DIR)/arch/arm64/configs/$(KERNEL_DEFCONFIG)
	echo -n > $(KERNEL_DIR)/.scmversion
	$(KERNEL_MAKE) $(KERNEL_DEFCONFIG)
	$(KERNEL_MAKE) bindeb-pkg -j$$(nproc)

$(KERNEL_HEADERS_PACKAGES): $(KERNEL_PACKAGE)

.PHONY: kernel-build		# compile kernel package
kernel-build: $(KERNEL_PACKAGE) $(KERNEL_HEADERS_PACKAGES)

.PHONY: kernel-menuconfig		# edit kernel config and save as defconfig
kernel-menuconfig:
	$(KERNEL_MAKE) $(KERNEL_DEFCONFIG)
	$(KERNEL_MAKE) HOSTCC=gcc menuconfig
	$(KERNEL_MAKE) savedefconfig
	mv $(KERNEL_DIR)/defconfig $(KERNEL_DIR)/arch/arm64/configs/$(KERNEL_DEFCONFIG)

.PHONY: kernel-build-image
kernel-build-image:
	$(KERNEL_MAKE) Image dtbs -j$$(nproc)

.PHONY: kernel-build-with-modules
kernel-build-with-modules:
	$(KERNEL_MAKE) Image modules dtbs -j$$(nproc)
	$(KERNEL_MAKE) modules_install INSTALL_MOD_PATH=$(CURDIR)/out/linux_modules

.PHONY: kernel-dts-update
kernel-dts-update:
	$(KERNEL_MAKE) dtbs -j$$(nproc)
	rsync --partial --checksum -rv $(KERNEL_DIR)/arch/arm64/boot/dts/rockchip/rk3328-rock64.dtb root@$(REMOTE_HOST):$(REMOTE_DIR)/boot/efi/dtb

.PHONY: kernel-update
kernel-update:
	rsync --partial --checksum -rv $(KERNEL_DIR)/arch/arm64/boot/Image root@$(REMOTE_HOST):$(REMOTE_DIR)/boot/efi/Image
	rsync --partial --checksum -rv $(KERNEL_DIR)/arch/arm64/boot/dts/rockchip/rk3328-rock64.dtb root@$(REMOTE_HOST):$(REMOTE_DIR)/boot/efi/dtb
	rsync --partial --checksum -av out/linux_modules/lib/ root@$(REMOTE_HOST):$(REMOTE_DIR)/lib
