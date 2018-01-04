.PHONY: loader-download-mode
loader-download-mode:
ifneq (,$(FLASH_SPI))
	rkdeveloptool db rkbin/rk33/rk3328_loader_v1.08.244_for_spi_nor_build_Aug_7_2017.bin
else
	rkdeveloptool db rkbin/rk33/rk3328_loader_ddr333_v1.08.244.bin
endif
	sleep 1s

.PHONY: loader-boot		# boot loader over USB
loader-boot: out/u-boot/idbloader.img
	make loader-download-mode
	rkdeveloptool rid
	rkdeveloptool wl 64 out/u-boot/clear.img
	rkdeveloptool wl 512 $(UBOOT_DIR)/u-boot.itb
	rkdeveloptool rd
	sleep 1s

ifneq (,$(USE_UBOOT_TPL))
	cat $(UBOOT_DIR)/tpl/u-boot-tpl.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool l
else
	cat rkbin/rk33/rk3328_ddr_786MHz_v1.06.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool l
endif
	cat u-boot/spl/u-boot-spl.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool L

.PHONY: loader-flash		# flash loader to the device
loader-flash: out/u-boot/idbloader.img
	make loader-download-mode
	sleep 1s
	rkdeveloptool rid
	rkdeveloptool wl 64 $<
	rkdeveloptool rd

.PHONY: loader-wipe		# clear loader
loader-wipe:
	dd if=/dev/zero of=out/u-boot/clear.img count=1
	make loader-download-mode
	sleep 1s
	rkdeveloptool rid
	rkdeveloptool wl 64 out/u-boot/clear.img
	rkdeveloptool rd
