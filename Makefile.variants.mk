.PHONY: xenial-minimal-rock64
xenial-minimal-rock64: xenial-minimal-rock64-$(IMAGE_SUFFIX)-armhf.img.xz \
	xenial-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

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

.PHONY: xenial-rock64		# build all xenial variants
xenial-rock64: xenial-minimal-rock64 \
	xenial-mate-rock64 \
	xenial-i3-rock64

.PHONY: artful-minimal-rock64
artful-minimal-rock64: artful-minimal-rock64-$(IMAGE_SUFFIX)-armhf.img.xz \
	artful-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: artful-rock64		# build all artful variants
artful-rock64: artful-minimal-rock64

.PHONY: stretch-rock64		# build all stretch variants
stretch-rock64: stretch-minimal-rock64

.PHONY: jessie-rock64		# build all jessie variants
jessie-rock64: jessie-minimal-rock64 \
	jessie-openmediavault-rock64

.PHONY: linux-rock64		# build all linux variants
linux-rock64: artful-rock64 \
	xenial-rock64 \
	stretch-rock64 \
	jessie-rock64 \
	linux-virtual
