UBOOT_MAKE ?= make -C $(UBOOT_DIR) \
	CROSS_COMPILE="ccache aarch64-linux-gnu-"

$(UBOOT_DIR)/.config: $(UBOOT_DIR)/configs/$(UBOOT_DEFCONFIG)
	$(UBOOT_MAKE) $(UBOOT_DEFCONFIG)

out/u-boot/idbloader.img: $(UBOOT_DIR)/.config $(BL31)
	cp -u $(BL31) u-boot/bl31.elf
	$(UBOOT_MAKE) -j $$(nproc)
	$(UBOOT_MAKE) -j $$(nproc) u-boot.itb
	mkdir -p out/u-boot
ifneq (,$(USE_UBOOT_TPL))
	$(UBOOT_DIR)/tools/mkimage -n rk3328 -T rksd -d $(UBOOT_DIR)/tpl/u-boot-tpl.bin $@.tmp
else
	$(UBOOT_DIR)/tools/mkimage -n rk3328 -T rksd -d rkbin/rk33/rk3328_ddr_786MHz_v1.06.bin $@.tmp
endif
	cat $(UBOOT_DIR)/spl/u-boot-spl.bin >> $@.tmp
	dd if=$(UBOOT_DIR)/u-boot.itb of=$@.tmp seek=$$((0x200-64)) conv=notrunc
	mv $@.tmp $@

.PHONY: u-boot-menuconfig		# edit u-boot config and save as defconfig
u-boot-menuconfig:
	$(UBOOT_MAKE) ARCH=arm64 $(UBOOT_DEFCONFIG)
	$(UBOOT_MAKE) ARCH=arm64 menuconfig
	$(UBOOT_MAKE) ARCH=arm64 savedefconfig
	mv $(UBOOT_DIR)/defconfig $(UBOOT_DIR)/configs/$(UBOOT_DEFCONFIG)

.PHONY: u-boot-build		# compile u-boot
u-boot-build:
	rm -f out/u-boot/idbloader.img
	make out/u-boot/idbloader.img

.PHONY: u-boot-clear
u-boot-clear:
	rm -rf out/u-boot/

out/u-boot/%/boot.scr: blobs/%.cmd
	mkdir -p $$(dirname $@)
	mkimage -C none -A arm -T script -d $< $@

out/u-boot/%/boot.img: out/u-boot/%/boot.scr
	dd if=/dev/zero of=$@ bs=1M count=2
	mkfs.vfat -n "u-boot-script" $@
	mcopy -sm -i $@ $< ::

u-boot-%.img: out/u-boot/%/boot.img out/u-boot/idbloader.img
	build/mk-image.sh -c rk3328 -t system -s 128 -b $< -o "$@.tmp"
	mv "$@.tmp" $@

.PHONY: u-boot-flash-spi
u-boot-flash-spi: u-boot-flash-spi.img.xz

.PHONY: u-boot-erase-spi
u-boot-erase-spi: u-boot-erase-spi.img.xz
