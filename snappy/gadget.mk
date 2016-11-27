include common.mk

all: build

clean:
	rm -rf $(GADGET_DIR)/boot-assets
	rm -f $(GADGET_DIR)/uboot.conf
	rm -f $(GADGET_DIR)/uboot.env
	rm -f $(GADGET_SNAP)

distclean: clean

u-boot:
	@if [ ! -d $(GADGET_DIR)/boot-assets ] ; then mkdir -p $(GADGET_DIR)/boot-assets; fi
	@if [ ! -f $(UBOOT_BIN) ]; then echo "Build u-boot first."; exit 1; fi
	cp -fa $(UBOOT_BIN) $(GADGET_DIR)/boot-assets/u-boot-with-dtb.bin

dtbs:
	@if [ ! -d $(GADGET_DIR)/boot-assets/dtbs ] ; then mkdir -p $(GADGET_DIR)/boot-assets/dtbs; fi
	dtc -Odtb -o $(GADGET_DIR)/boot-assets/dtbs/sun50i-a64-pine64-plus.dtb $(BLOBS_DIR)/pine64.dts
	dtc -Odtb -o $(GADGET_DIR)/boot-assets/dtbs/sun50i-a64-pine64.dtb $(BLOBS_DIR)/pine64noplus.dts
	dtc -Odtb -o $(GADGET_DIR)/boot-assets/dtbs/sun50i-a64-pine64so.dtb $(BLOBS_DIR)/pine64so.dts

preload: u-boot dtbs
	cp -fa $(BLOBS_DIR)/boot0.bin $(GADGET_DIR)/boot-assets/boot0.bin
	mkenvimage -r -s 131072  -o $(GADGET_DIR)/uboot.env $(GADGET_DIR)/uboot.env.in
	@if [ ! -f $(GADGET_DIR)/uboot.conf ]; then ln -s uboot.env $(GADGET_DIR)/uboot.conf; fi

snappy: preload
	snapcraft snap gadget

build: dtbs preload snappy

.PHONY: u-boot dtbs preload snappy build
