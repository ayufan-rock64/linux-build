UBOOT_MAKE ?= make -C $(UBOOT_DIR) \
	CROSS_COMPILE="ccache aarch64-linux-gnu-"

$(UBOOT_DIR)/.config: $(UBOOT_DIR)/configs/$(UBOOT_DEFCONFIG)
	$(UBOOT_MAKE) $(UBOOT_DEFCONFIG)

out/u-boot/idbloader.img: $(UBOOT_DIR)/.config
	cp rkbin/rk33/rk3328_bl31_v1.34.bin u-boot/bl31.elf
	$(UBOOT_MAKE) -j $$(nproc)
	$(UBOOT_MAKE) -j $$(nproc) u-boot.itb
	mkdir -p out/u-boot
	$(UBOOT_DIR)/tools/mkimage -n rk3328 -T rksd -d $(UBOOT_DIR)/tpl/u-boot-tpl.bin $@.tmp
	cat $(UBOOT_DIR)/spl/u-boot-spl.bin >> $@.tmp
	dd if=$(UBOOT_DIR)/u-boot.itb of=$@.tmp seek=$$((0x200-64)) conv=notrunc
	mv $@.tmp $@

.PHONY: u-boot-menuconfig		# edit u-boot config and save as defconfig
u-boot-menuconfig:
	$(UBOOT_MAKE) ARCH=arm64 $(UBOOT_DEFCONFIG)
	$(UBOOT_MAKE) ARCH=arm64 menuconfig
	$(UBOOT_MAKE) ARCH=arm64 savedefconfig
	cp $(UBOOT_DIR)/defconfig $(UBOOT_DIR)/configs/$(UBOOT_DEFCONFIG)

.PHONY: u-boot-boot
u-boot-boot:		# boot u-boot over USB
	cat rkbin/rk33/rk3328_ddr_786MHz_v1.06.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool l
	cat u-boot/spl/u-boot-spl.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool L

.PHONY: u-boot-flash-spi		# flash u-boot to SPI
u-boot-flash-spi: out/u-boot/idbloader.img
	rkdeveloptool db rkbin/rk33/rk3328_loader_v1.08.244_for_spi_nor_build_Aug_7_2017.bin
	rkdeveloptool rid
	rkdeveloptool wl 64 $<
	rkdeveloptool rd

.PHONY: u-boot-clear-spi		# clear u-boot to SPI
u-boot-clear-spi: out/u-boot/idbloader.img
	rkdeveloptool db rkbin/rk33/rk3328_loader_v1.08.244_for_spi_nor_build_Aug_7_2017.bin
	rkdeveloptool rid
	rkdeveloptool wl 64 $<
	rkdeveloptool rd

.PHONY: u-boot		# compile u-boot
u-boot: out/u-boot/idbloader.img
