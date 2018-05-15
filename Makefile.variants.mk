.PHONY: stretch-minimal-$(BOARD_TARGET)
stretch-minimal-$(BOARD_TARGET): stretch-minimal-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: jessie-openmediavault-$(BOARD_TARGET)
stretch-openmediavault-$(BOARD_TARGET): stretch-openmediavault-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-armhf.img.xz \
	stretch-openmediavault-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: bionic-minimal-$(BOARD_TARGET)
bionic-minimal-$(BOARD_TARGET): bionic-minimal-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-armhf.img.xz \
	bionic-minimal-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: bionic-containers-$(BOARD_TARGET)
bionic-containers-$(BOARD_TARGET): bionic-containers-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: bionic-mate-$(BOARD_TARGET)
bionic-mate-$(BOARD_TARGET): bionic-mate-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: bionic-lxde-$(BOARD_TARGET)
bionic-lxde-$(BOARD_TARGET): bionic-lxde-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: bionic-$(BOARD_TARGET)		# build all bionic variants
bionic-$(BOARD_TARGET): bionic-minimal-$(BOARD_TARGET) \
	bionic-containers-$(BOARD_TARGET) \
	bionic-lxde-$(BOARD_TARGET)

.PHONY: stretch-$(BOARD_TARGET)		# build all stretch variants
stretch-$(BOARD_TARGET): stretch-minimal-$(BOARD_TARGET) \
	stretch-openmediavault-$(BOARD_TARGET)

.PHONY: linux-$(BOARD_TARGET)		# build all linux variants
linux-$(BOARD_TARGET): \
	bionic-$(BOARD_TARGET) \
	stretch-$(BOARD_TARGET) \
	linux-virtual \
	u-boot-flash-spi-$(BOARD_TARGET) \
	u-boot-erase-spi-$(BOARD_TARGET)

.PHONY: linux-minimal-$(BOARD_TARGET)		# build all linux variants
linux-minimal-$(BOARD_TARGET): \
	bionic-minimal-$(BOARD_TARGET) \
	bionic-containers-$(BOARD_TARGET) \
	stretch-minimal-$(BOARD_TARGET) \
	stretch-openmediavault-$(BOARD_TARGET) \
	linux-virtual \
	u-boot-flash-spi-$(BOARD_TARGET) \
	u-boot-erase-spi-$(BOARD_TARGET)

.PHONY: linux-packages-$(BOARD_TARGET)		# build all packages only
linux-packages-$(BOARD_TARGET): \
	linux-virtual \
	linux-package \
	u-boot-flash-spi-$(BOARD_TARGET) \
	u-boot-erase-spi-$(BOARD_TARGET)
