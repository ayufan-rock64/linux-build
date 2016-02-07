# U-Boot boot0 compatibility

This script extends a compiled U-Boot with other required parts so it is
bootable by the A64 boot0 boot loader.

To be fully compatible with all the scripting in this module, clone the U-Boot
tree into `build-pine64-image/u-boot-pine64` folder.

## Get U-Boot tree

```bash
git clone --depth 1 --branch pine64-hacks --single-branch git@github.com:longsleep/u-boot-pine64.git u-boot-pine64
```

## Compile U-Boot

```bash
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- sun50iw1p1_config
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
```

## Get the Linux BSP (Lichee)

Download from `http://wiki.pine64.org/index.php/Pine_A64_Software_Release`
and extract into `build-pine64-image/lichee`.

## Get ARM Trust Firmware (ATF)

Similar to U-Boot, this is based on an upstream project with A64 specific
patches from Allwinner.

To be fully compatible with all the scripting in this module, clone the ATF
tree into `build-pine64-image/arm-trusted-firmware-pine64` folder.

```bash
git clone --depth 1 --branch lichee-dev-1.0-fix-compile --single-branch https://github.com/longsleep/arm-trusted-firmware-pine64.git arm-trusted-firmware-pine64
```

## Compile ARM Trust Firmware (ATF)

Note that the ATF is a 32bit application and thus build with the 32bit ARM
toolchain.

```bash
make clean && make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- PLAT=sun50iw1p1
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

To do this, you need the BSP extracted to `build-pine64-image/lichee`, the
ARM Trusted Firmware ready and compiled in `build-pine64-image/arm-trusted-firmware-pine64` and the Suxi pack tools compiled in
`build-pine64-image/sunxi-pack-tools`.

```bash
./u-boot-postprocess.sh
```

## Next steps

Now that you have the boot loader, you actually can create a disk image with
it. See the `simpleimage` folder. Copy the created `out/u-boot-with-dtb.bin`
file into the `simpleimage` folder to be used there.
