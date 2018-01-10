.PHONY: xenial-minimal-rock64
xenial-minimal-rock64: xenial-minimal-rock64-$(IMAGE_SUFFIX)-armhf.img.xz \
	xenial-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: xenial-containers-rock64
xenial-containers-rock64: xenial-containers-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: xenial-mate-rock64
xenial-mate-rock64: xenial-mate-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: xenial-i3-rock64
xenial-i3-rock64: xenial-i3-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: jessie-minimal-rock64
jessie-minimal-rock64: jessie-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: jessie-openmediavault-rock64
jessie-openmediavault-rock64: jessie-openmediavault-rock64-$(IMAGE_SUFFIX)-armhf.img.xz \
	jessie-openmediavault-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: stretch-minimal-rock64
stretch-minimal-rock64: stretch-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: jessie-openmediavault-rock64
stretch-openmediavault-rock64: stretch-openmediavault-rock64-$(IMAGE_SUFFIX)-armhf.img.xz \
	stretch-openmediavault-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: xenial-rock64		# build all xenial variants
xenial-rock64: xenial-minimal-rock64 \
	xenial-containers-rock64 \
	xenial-mate-rock64 \
	xenial-i3-rock64

.PHONY: bionic-minimal-rock64
bionic-minimal-rock64: bionic-minimal-rock64-$(IMAGE_SUFFIX)-armhf.img.xz \
	bionic-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: bionic-mate-rock64
bionic-mate-rock64: bionic-mate-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: bionic-rock64		# build all bionic variants
bionic-rock64: bionic-minimal-rock64 \
	bionic-mate-rock64

.PHONY: stretch-rock64		# build all stretch variants
stretch-rock64: stretch-minimal-rock64 \
	stretch-openmediavault-rock64

.PHONY: jessie-rock64		# build all jessie variants
jessie-rock64: jessie-minimal-rock64 \
	jessie-openmediavault-rock64

.PHONY: linux-rock64		# build all linux variants
linux-rock64: \
	bionic-rock64 \
	xenial-rock64 \
	stretch-rock64 \
	jessie-rock64 \
	linux-virtual \
	u-boot-flash-spi \
	u-boot-erase-spi

.PHONY: linux-minimal-rock64		# build all linux variants
linux-minimal-rock64: \
	bionic-minimal-rock64 \
	xenial-minimal-rock64 \
	xenial-containers-rock64 \
	stretch-minimal-rock64 \
	stretch-openmediavault-rock64 \
	jessie-minimal-rock64 \
	jessie-openmediavault-rock64 \
	linux-virtual \
	u-boot-flash-spi \
	u-boot-erase-spi
