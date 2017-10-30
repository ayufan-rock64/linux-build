export RELEASE_NAME ?= 0.1~dev
export RELEASE ?= 1
export BOOT_TOOLS_BRANCH ?= master
export KERNEL_DIR ?= kernel
export UBOOT_DIR ?= u-boot

KERNEL_EXTRAVERSION ?= -rockchip-ayufan-$(RELEASE)
KERNEL_DEFCONFIG ?= rockchip_linux_defconfig
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
PACKAGES := linux-rock64-package-$(RELEASE_NAME)_all.deb $(KERNEL_PACKAGE) $(KERNEL_HEADERS_PACKAGES)

IMAGE_SUFFIX := $(RELEASE_NAME)-$(RELEASE)

all: linux-rock64

.PHONY: info
info:
	@echo version: $(KERNEL_VERSION)
	@echo release: $(KERNEL_RELEASE)

.PHONY: help
help:
	@echo Available targets:
	@grep '^.PHONY: .*#' Makefile | cut -d: -f2- | expand -t20 | sort
	@echo
	@echo Extra targets:
	@echo " " $$(grep '^.PHONY: [^#]*$$' Makefile | cut -d: -f2- | sort)

.PHONY: sync		# download all subtrees
sync:
	repo init -u https://github.com/ayufan-rock64/linux-manifests -b default --depth=1 --no-clone-bundle
	repo sync -j 20 -c --force-sync

include Makefile.uboot.mk

linux-rock64-$(RELEASE_NAME)_arm64.deb: $(PACKAGES)
	fpm -s empty -t deb -n linux-rock64 -v $(RELEASE_NAME) \
		-p $@ \
		--deb-priority optional --category admin \
		--depends "linux-rock64-package (= $(RELEASE_NAME))" \
		--depends "linux-image-$(KERNEL_RELEASE) (= $(RELEASE_NAME))" \
		--depends "linux-headers-$(KERNEL_RELEASE) (= $(RELEASE_NAME))" \
		--force \
		--url https://gitlab.com/ayufan-rock64/linux-build \
		--description "Rock64 Linux virtual package: depends on kernel and compatibility package" \
		-m "Kamil Trzciński <ayufan@ayufan.eu>" \
		--license "MIT" \
		--vendor "Kamil Trzciński" \
		-a arm64

linux-rock64-package-$(RELEASE_NAME)_all.deb: package
	chmod -R go-w $<
	fpm -s dir -t deb -n linux-rock64-package -v $(RELEASE_NAME) \
		-p $@ \
		--deb-priority optional --category admin \
		--force \
		--depends figlet \
		--depends cron \
		--depends gdisk \
		--depends parted \
		--deb-compression bzip2 \
		--deb-field "Multi-Arch: foreign" \
		--after-install package/scripts/postinst.deb \
		--before-remove package/scripts/prerm.deb \
		--url https://gitlab.com/ayufan-rock64/linux-build \
		--description "Rock64 Linux support package" \
		--config-files /boot/efi/extlinux/ \
		-m "Kamil Trzciński <ayufan@ayufan.eu>" \
		--license "MIT" \
		--vendor "Kamil Trzciński" \
		-a all \
		package/root/=/

linux-rock64-package-$(RELEASE_NAME)_all.rpm: package
	chmod -R go-w $<
	fpm -s dir -t rpm -n linux-rock64-package -v $(RELEASE_NAME) \
		-p $@ \
		--force \
		--depends figlet \
		--depends cron \
		--depends gdisk \
		--depends parted \
		--after-install package/scripts/postinst.deb \
		--before-remove package/scripts/prerm.deb \
		--url https://gitlab.com/ayufan-rock64/linux-build \
		--description "Rock64 Linux support package" \
		--config-files /boot/efi/extlinux/ \
		-m "Kamil Trzciński <ayufan@ayufan.eu>" \
		--license "MIT" \
		--vendor "Kamil Trzciński" \
		-a all \
		package/root/=/

%.tar.xz: %.tar
	pxz -f -3 $<

%.img.xz: %.img
	pxz -f -3 $<

BUILD_SYSTEMS := artful zesty xenial jessie stretch
BUILD_VARIANTS := minimal mate i3 openmediavault
BUILD_ARCHS := armhf arm64
BUILD_MODELS := rock64

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

$(KERNEL_PACKAGE): kernel/arch/arm64/configs/$(KERNEL_DEFCONFIG)
	echo -n > kernel/.scmversion
	$(KERNEL_MAKE) $(KERNEL_DEFCONFIG)
	$(KERNEL_MAKE) bindeb-pkg -j$(shell nproc)

$(KERNEL_HEADERS_PACKAGES): $(KERNEL_PACKAGE)

.PHONY: kernelpkg		# compile kernel package
kernelpkg: $(KERNEL_PACKAGE) $(KERNEL_HEADERS_PACKAGES)

.PHONY: linux-package		# compile linux compatibility package
linux-package: linux-rock64-package-$(RELEASE_NAME)_all.deb linux-rock64-package-$(RELEASE_NAME)_all.rpm

.PHONY: linux-virtual		# compile linux package tying compatiblity package and kernel package
linux-virtual: linux-rock64-$(RELEASE_NAME)_arm64.deb

.PHONY: xenial-minimal-rock64
xenial-minimal-rock64: xenial-minimal-rock64-$(IMAGE_SUFFIX)-armhf.img.xz xenial-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: xenial-mate-rock64
xenial-mate-rock64: xenial-mate-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: xenial-i3-rock64
xenial-i3-rock64: xenial-i3-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: jessie-minimal-rock64
jessie-minimal-rock64: jessie-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: jessie-openmediavault-rock64
jessie-openmediavault-rock64: jessie-openmediavault-rock64-$(IMAGE_SUFFIX)-armhf.img.xz jessie-openmediavault-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: stretch-minimal-rock64
stretch-minimal-rock64: stretch-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: xenial-rock64		# build all xenial variants
xenial-rock64: xenial-minimal-rock64 xenial-mate-rock64 xenial-i3-rock64

.PHONY: artful-minimal-rock64
artful-minimal-rock64: artful-minimal-rock64-$(IMAGE_SUFFIX)-armhf.img.xz artful-minimal-rock64-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: artful-rock64		# build all artful variants
artful-rock64: artful-minimal-rock64

.PHONY: stretch-rock64		# build all stretch variants
stretch-rock64: stretch-minimal-rock64

.PHONY: jessie-rock64		# build all jessie variants
jessie-rock64: jessie-minimal-rock64 jessie-openmediavault-rock64

.PHONY: linux-rock64		# build all linux variants
linux-rock64: artful-rock64 xenial-rock64 stretch-rock64 jessie-rock64 linux-virtual

.PHONY: pull-trees		# merge all subtree into current tree
pull-trees:
	git subtree pull --prefix build https://github.com/rockchip-linux/build debian
	git subtree pull --prefix build https://github.com/rock64-linux/build debian

.PHONY: u-boot-menuconfig		# edit u-boot config and save as defconfig
u-boot-menuconfig:
	$(UBOOT_MAKE) ARCH=arm64 $(UBOOT_DEFCONFIG)
	$(UBOOT_MAKE) ARCH=arm64 menuconfig
	$(UBOOT_MAKE) ARCH=arm64 savedefconfig
	cp $(UBOOT_DIR)/defconfig $(UBOOT_DIR)/configs/$(UBOOT_DEFCONFIG)

.PHONY: kernel-menuconfig		# edit kernel config and save as defconfig
kernel-menuconfig:
	$(KERNEL_MAKE) $(KERNEL_DEFCONFIG)
	$(KERNEL_MAKE) HOSTCC=gcc menuconfig
	$(KERNEL_MAKE) savedefconfig
	cp $(KERNEL_DIR)/defconfig $(KERNEL_DIR)/arch/arm64/configs/$(KERNEL_DEFCONFIG)

REMOTE_HOST ?= rock64.home

kernel-build:
	$(KERNEL_MAKE) Image dtbs -j$$(nproc)

kernel-build-with-modules:
	$(KERNEL_MAKE) Image modules dtbs -j$$(nproc)
	$(KERNEL_MAKE) modules_install INSTALL_MOD_PATH=$(CURDIR)/tmp/linux_modules

kernel-update:
	rsync --partial --checksum -rv $(KERNEL_DIR)/arch/arm64/boot/Image root@$(REMOTE_HOST):$(REMOTE_DIR)/boot/efi/Image
	rsync --partial --checksum -rv $(KERNEL_DIR)/arch/arm64/boot/dts/rockchip/rk3328-rock64.dtb root@$(REMOTE_HOST):$(REMOTE_DIR)/boot/efi/dtb
	rsync --partial --checksum -av tmp/linux_modules/lib/ root@$(REMOTE_HOST):$(REMOTE_DIR)/lib

.PHONY: shell		# run docker shell to build image
shell:
	@echo Building environment...
	@docker build -q -t rock64-linux:build-environment environment/
	@echo Entering shell...
	@docker run --rm \
		-it \
		-e HOME -v $(HOME):$(HOME) \
		-e USER \
		-u $$(id -u):$$(id -g) \
		$$(id -Gz | xargs -0 -n1 -I{} echo "--group-add={}") \
		-v /etc/passwd:/etc/passwd:ro \
		-v /dev/bus/usb:/dev/bus/usb \
		--privileged \
		-h rock64-build-env \
		-v $(CURDIR):$(CURDIR) \
		-w $(CURDIR) \
		rock64-linux:build-environment
