# Binary blobs extracted from A64 BSP

Not everything to boot an A64 has been released as source. While that is
this is questionable in itself, for now one has to stick with the blobs
as found in the BSP. This folder holds the collection as extracted
from the BSP found on the Pine64 wiki.

BSP download: http://wiki.pine64.org/index.php/Pine_A64_Software_Release

## Boot0 boot loader

The boot0 loader is the first thing executed. It is extracted from the
Android image. At this time, Allwinner has not released the source code for
boot0 for A64.

Android image download: http://wiki.pine64.org/index.php/Pine_A64_Software_Release#Android_Image_Release_20160112

### Extract yourself like this

```bash
dd if="$IMAGE" bs=1k skip=8 count=32 of=boot0.bin
```

## SCP firmware for the on-SoC management controller

Binary blob scp.bin taken from the BSP `tools/pack/chips/sun50iw1p1/bin/scp.bin`.

## Device tree for U-Boot and BSP Kernel

The U-Boot uses its own FDT. A binary dtb has been extraced from the BSP `out/sun50iw1p1/android/common/sunxi.dtb` and dumped as source to `pine64.dts` with the `fdtdump`
utility from git://git.kernel.org/pub/scm/utils/dtc/dtc.git. This device tree
also works for booting the BSP Kernel. Some values in the device tree have
been changed to match the values which are found in the Android image.

## FEX description for U-Boot

The FEX file is minimal and does not contain any settings. It is just required
to get the corret boot loader format to make the U-Boot acceptable to boot0.
