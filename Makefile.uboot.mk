UBOOT_OUTPUT_DIR ?= $(CURDIR)/tmp/u-boot-$(BOARD_TARGET)
UBOOT_LOADER ?= out/u-boot-$(BOARD_TARGET)/idbloader.img
UBOOT_MAKE ?= make -C $(UBOOT_DIR) KBUILD_OUTPUT=$(UBOOT_OUTPUT_DIR) BL31=$(BL31) \
	CROSS_COMPILE="ccache aarch64-linux-gnu-"

tmp/u-boot-$(BOARD_TARGET)/.config: $(UBOOT_DIR)/configs/$(UBOOT_DEFCONFIG)
	$(UBOOT_MAKE) $(UBOOT_DEFCONFIG) 

$(UBOOT_LOADER): tmp/u-boot-$(BOARD_TARGET)/.config $(BL31)
	$(UBOOT_MAKE) -j $$(nproc)
	$(UBOOT_MAKE) -j $$(nproc) u-boot.itb
	mkdir -p out/u-boot-$(BOARD_TARGET)
ifneq (,$(USE_UBOOT_SPL))
	$(UBOOT_OUTPUT_DIR)/tools/mkimage -n $(BOARD_CHIP) -T rksd -d $(UBOOT_OUTPUT_DIR)/spl/u-boot-spl.bin $@.tmp
else ifneq (,$(USE_UBOOT_TPL))
	$(UBOOT_OUTPUT_DIR)/tools/mkimage -n $(BOARD_CHIP) -T rksd -d $(UBOOT_OUTPUT_DIR)/tpl/u-boot-tpl.bin $@.tmp
	cat $(UBOOT_OUTPUT_DIR)/spl/u-boot-spl.bin >> $@.tmp
else ifeq (rock64,$(BOARD_TARGET))
	$(UBOOT_OUTPUT_DIR)/tools/mkimage -n $(BOARD_CHIP) -T rksd -d rkbin/rk33/rk3328_ddr_786MHz_v1.06.bin $@.tmp
	cat $(UBOOT_OUTPUT_DIR)/spl/u-boot-spl.bin >> $@.tmp
else ifeq (rockpro64,$(BOARD_TARGET))
	$(UBOOT_OUTPUT_DIR)/tools/mkimage -n $(BOARD_CHIP) -T rksd -d rkbin/rk33/rk3399_ddr_800MHz_v1.08.bin $@.tmp
	cat $(UBOOT_OUTPUT_DIR)/spl/u-boot-spl.bin >> $@.tmp
else
	@echo "Invalid $(BOARD_TARGET)"
	@exit 1
endif
	dd if=$(UBOOT_OUTPUT_DIR)/u-boot.itb of=$@.tmp seek=$$((0x200-64)) conv=notrunc
	mv $@.tmp $@

.PHONY: u-boot-menuconfig		# edit u-boot config and save as defconfig
u-boot-menuconfig:
	$(UBOOT_MAKE) ARCH=arm64 $(UBOOT_DEFCONFIG)
	$(UBOOT_MAKE) ARCH=arm64 menuconfig
	$(UBOOT_MAKE) ARCH=arm64 savedefconfig
	mv $(UBOOT_OUTPUT_DIR)/defconfig $(UBOOT_DIR)/configs/$(UBOOT_DEFCONFIG)

.PHONY: u-boot-build		# compile u-boot
u-boot-build:
	rm -f $(UBOOT_LOADER)
	make $(UBOOT_LOADER)

.PHONY: u-boot-clear
u-boot-clear:
	rm -rf $(UBOOT_LOADER)/..

out/u-boot/%/boot.scr: blobs/%.cmd
	mkdir -p $$(dirname $@)
	mkimage -C none -A arm -T script -d $< $@

out/u-boot/%/boot.img: out/u-boot/%/boot.scr
	dd if=/dev/zero of=$@ bs=1M count=2
	mkfs.vfat -n "u-boot-script" $@
	mcopy -sm -i $@ $< ::

u-boot-%-$(BOARD_TARGET).img: out/u-boot/%/boot.img $(UBOOT_LOADER)
	build/mk-image.sh -c $(BOARD_CHIP) -d out/u-boot-$(BOARD_TARGET) -t system -s 128 -b $< -o "$@.tmp"
	mv "$@.tmp" $@

.PHONY: u-boot-flash-spi-$(BOARD_TARGET)
u-boot-flash-spi-$(BOARD_TARGET): u-boot-flash-spi-$(BOARD_TARGET).img.xz

.PHONY: u-boot-erase-spi-$(BOARD_TARGET)
u-boot-erase-spi-$(BOARD_TARGET): u-boot-erase-spi-$(BOARD_TARGET).img.xz
