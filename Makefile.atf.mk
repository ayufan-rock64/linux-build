BL31 ?= arm-trusted-firmware/build/$(ATF_PLAT)/release/bl31/bl31.elf

arm-trusted-firmware/build/$(ATF_PLAT)/release/bl31/bl31.elf: arm-trusted-firmware
	make -C $< realclean
	make -C $< CROSS_COMPILE=aarch64-linux-gnu- M0_CROSS_COMPILE=arm-linux-gnueabi- PLAT=$(ATF_PLAT) bl31

arm-trusted-firmware/build/$(ATF_PLAT)/debug/bl31/bl31.elf: arm-trusted-firmware
	make -C $< realclean
	make -C $< CROSS_COMPILE=aarch64-linux-gnu- M0_CROSS_COMPILE=arm-linux-gnueabi- PLAT=$(ATF_PLAT) bl31 DEBUG=1

.PHONY: atf-build
atf-build: $(BL31)

.PHONY: atf-clean
atf-clean:
	rm -rf arm-trusted-firmware/build
