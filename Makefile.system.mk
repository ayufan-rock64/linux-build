PACKAGES := linux-$(BOARD_TARGET)-package-$(RELEASE_NAME)_all.deb \
	linux-$(BOARD_TARGET)-$(RELEASE_NAME)_arm64.deb

%.tar.xz: %.tar
	pxz -f -3 $<

%.img.xz: %.img
	pxz -f -3 $<

%.img: $(PACKAGES)
	sudo bash rootfs/build-system-image.sh \
		"$$(readlink -f $@)" \
		"$(filter $(BUILD_SYSTEMS), $(subst -, ,$(*F)))" \
		"$(filter $(BUILD_VARIANTS), $(subst -, ,$(*F)))" \
		"$(filter $(BUILD_ARCHS), $(subst -, ,$(*F)))" \
		"$(filter $(BUILD_MODELS), $(subst -, ,$(*F)))" \
		$^
