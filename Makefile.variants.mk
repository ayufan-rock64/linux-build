.PHONY: stretch-minimal
stretch-minimal: stretch-minimal-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: jessie-openmediavault
stretch-openmediavault: stretch-openmediavault-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-armhf.img.xz \
	stretch-openmediavault-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: bionic-minimal
bionic-minimal: bionic-minimal-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-armhf.img.xz \
	bionic-minimal-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: bionic-containers
bionic-containers: bionic-containers-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: bionic-mate
bionic-mate: bionic-mate-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: bionic-lxde
bionic-lxde: bionic-lxde-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: bionic		# build all bionic variants
bionic: bionic-minimal \
	bionic-containers \
	bionic-lxde

.PHONY: stretch		# build all stretch variants
stretch: stretch-minimal \
	stretch-openmediavault

.PHONY: linux-variants		# build all linux variants
linux-variants: \
	bionic \
	stretch \
	linux-virtual

.PHONY: linux-minimal		# build all linux variants
linux-minimal: \
	bionic-minimal \
	bionic-containers \
	stretch-minimal \
	stretch-openmediavault \
	linux-virtual
