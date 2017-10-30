PACKAGES := linux-rock64-package-$(RELEASE_NAME)_all.deb $(KERNEL_PACKAGE) $(KERNEL_HEADERS_PACKAGES)

%.tar.xz: %.tar
	pxz -f -3 $<

%.img.xz: %.img
	pxz -f -3 $<

%-system.img: $(PACKAGES) linux-rock64-$(RELEASE_NAME)_arm64.deb
	sudo bash rootfs/build-system-image.sh \
		"$$(readlink -f $@)" \
		"$$(readlink -f $(subst -system.img,-boot.img,$@))" \
		"$(filter $(BUILD_SYSTEMS), $(subst -, ,$@))" \
		"$(filter $(BUILD_VARIANTS), $(subst -, ,$@))" \
		"$(filter $(BUILD_ARCHS), $(subst -, ,$@))" \
		"$(filter $(BUILD_MODELS), $(subst -, ,$@))" \
		$^

%.img: %-system.img out/u-boot/idbloader.img
	build/mk-image.sh -c rk3328 -t system -r "$<" -b "$(subst -system.img,-boot.img,$<)" -o "$@.tmp"
	mv "$@.tmp" "$@"