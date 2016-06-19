# U-Boot boot0 compatibility

This script extends a compiled U-Boot with other required parts so it is
bootable by the A64 boot0 boot loader.

To be fully compatible with all the scripting in this module, clone the U-Boot
tree into `build-pine64-image/u-boot-pine64` folder.

BSP U-Boot is loaded in 32-bit mode. So to compile U-Boot you need a properly set
up gcc-arm-linux-gnueabihf toolchain. The recommended version to compile
U-Boot is 5.3.

## Get U-Boot tree

```bash
git clone --depth 1 --branch pine64-hacks --single-branch https://github.com/longsleep/u-boot-pine64.git u-boot-pine64
```

## Compile U-Boot

```bash
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- sun50iw1p1_config
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
```

## Get ARM Trust Firmware (ATF)

Similar to U-Boot, this is based on an upstream project with A64 specific
patches from Allwinner. Andre Przywara has cleaned up the Allwinner
patches - thanks @apritzel. Make sure you use ATF compatible with BSP
U-Boot (i keep a fork with the allwinner-a64-bsp branch).

To be fully compatible with all the scripting in this module, clone the ATF
tree into `build-pine64-image/arm-trusted-firmware-pine64` folder.

```bash
git clone --branch allwinner-a64-bsp --single-branch https://github.com/longsleep/arm-trusted-firmware.git arm-trusted-firmware-pine64
```

## Compile ARM Trust Firmware (ATF)

The recommended aarch64 toolchain to compile ATF is 5.3 (same as for
the Kernel).

```bash
make clean
make ARCH=arm CROSS_COMPILE=aarch64-linux-gnu- PLAT=sun50iw1p1 bl31
```

This creates `build/sun50iw1p1/release/bl31.bin` which will be picked up
from there later when merging U-Boot.

## Sunxi pack tools

The pack tools are part of the BSP packge, but i split them into a separate
repository so they can be easily used and retrieved when needed. As these
tools run on your build system, no cross compiling is required. Put them into
`build-bine64-image/sunxi-pack-tools` to be compatible with the scripts.

```bash
git clone https://github.com/longsleep/sunxi-pack-tools.git sunxi-pack-tools
make -C sunxi-pack-tools
```

## Merge U-Boot with other parts

To make boot0 accept and boot U-Boot, it needs to be correctly prefixed
and extended with the ATF.

In addition some blobs, and the device tree are required to create this
U-Boot bootloader format whre provided in the `build-pine64-image/blobs`
directory). So have the ATF ready and compiled in `build-pine64-image/arm-trusted-firmware-pine64` and the Suxi pack tools compiled in `build-pine64-image/sunxi-pack-tools`.

```bash
./u-boot-postprocess.sh
```

This creates `out/u-boot-with-dtb.bin` which is correctly prefixed, combined with ATF and FTD wich makes it acceptable for Allwinner's boot0.

## Next steps

Now that you have the boot loader, you actually can create a disk image with
it. See the `simpleimage` folder. Copy the created `out/u-boot-with-dtb.bin`
file into the `simpleimage` folder to be used there.

