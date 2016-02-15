# U-Boot boot0 compatibility

This script extends a compiled U-Boot with other required parts so it is
bootable by the A64 boot0 boot loader.

To be fully compatible with all the scripting in this module, clone the U-Boot
tree into `build-pine64-image/u-boot-pine64` folder.

A64 loads ATF and  U-Boot in 32bit mode. So to compile both you need a
properly set up gcc-arm-linux-gnueabihf toolchain. The recommended version to
compile U-Boot and ATF is 4.8. The U-Boot tree will not compile with 5.0 or
newer.

## Get U-Boot tree

```bash
git clone --depth 1 --branch pine64-hacks --single-branch git@github.com:longsleep/u-boot-pine64.git u-boot-pine64
```

## Compile U-Boot

```bash
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- sun50iw1p1_config
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
```

## Get ARM Trust Firmware (ATF)

Similar to U-Boot, this is based on an upstream project with A64 specific
patches from Allwinner.

To be fully compatible with all the scripting in this module, clone the ATF
tree into `build-pine64-image/arm-trusted-firmware-pine64` folder.

```bash
git clone --depth 1 --branch pine64-hacks --single-branch https://github.com/longsleep/arm-trusted-firmware-pine64.git arm-trusted-firmware-pine64
```

## Compile ARM Trust Firmware (ATF)

The ATF has the toolchain it uses hardcoded in the Makefile. See CROSS_COMPILE =
in line 31 if you want to change it. Defaults to `aarch64-linux-gnu-`.

```bash
make clean && make ARCH=arm PLAT=sun50iw1p1
```

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

When the `u-boot-sun50iw1p1.bin` was created by compling it can be used
to merge it with the other parts required to be accepted by A64 boot0 so it
actually can be booted.

To do this, you need some blobs from the BSP (provided in the `build-pine64-image/blobs`
directory), the ARM Trusted Firmware ready and compiled in `build-pine64-image/arm-trusted-firmware-pine64` and the Suxi pack tools compiled in `build-pine64-image/sunxi-pack-tools`.

```bash
./u-boot-postprocess.sh
```

## Next steps

Now that you have the boot loader, you actually can create a disk image with
it. See the `simpleimage` folder. Copy the created `out/u-boot-with-dtb.bin`
file into the `simpleimage` folder to be used there.
