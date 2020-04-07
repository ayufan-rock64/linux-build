%.tar.xz: %.tar
	pxz -f -3 $<

%.img.xz: %.img
	pxz -f -3 $<

%.img: $(PACKAGES)
	export ROOTFS_VERSION="$(LATEST_ROOTFS_VERSION)"; \
	sudo -E unshare -m -u -i -p --mount-proc --fork -- \
		bash rootfs/build-system-image.sh \
		"$$(readlink -f $@)" \
		"$(filter $(BUILD_SYSTEMS), $(subst -, ,$(*F)))" \
		"$(filter $(BUILD_VARIANTS), $(subst -, ,$(*F)))" \
		"$(filter $(BUILD_ARCHS), $(subst -, ,$(*F)))" \
		"$(filter $(BUILD_MODELS), $(subst -, ,$(*F)))" \
		$^
