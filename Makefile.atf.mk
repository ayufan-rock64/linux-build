BL31 ?= arm-trusted-firmware/build/rk3328/release/bl31/bl31.elf

arm-trusted-firmware/build/rk3328/release/bl31/bl31.elf: arm-trusted-firmware
	make -C $< realclean
	make -C $< CROSS_COMPILE=aarch64-linux-gnu- PLAT=rk3328 bl31

arm-trusted-firmware/build/rk3328/debug/bl31/bl31.elf: arm-trusted-firmware
	make -C $< realclean
	make -C $< CROSS_COMPILE=aarch64-linux-gnu- PLAT=rk3328 bl31 DEBUG=1

.PHONY: atf-build
atf-build: $(BL31)

.PHONY: atf-clean
atf-clean:
	rm -rf arm-trusted-firmware/build
