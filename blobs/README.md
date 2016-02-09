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

### Extract yourself like this

```bash
dd if="$IMAGE" bs=1k skip=8 count=32 of=boot0.bin
```

## SCP firmware for the on-SoC management controller

Binary blob scp.bin taken from the BSP `tools/pack/chips/sun50iw1p1/bin/scp.bin`.

## Device tree for U-Boot

The U-Boot uses its own FDT. The binary is taken from the BSP `out/sun50iw1p1/android/common/sunxi.dtb`.

## FEX description for U-Boot

The FEX file defines various aspects of how the SoC works. There are multiple
FEX boot configurations found in the BSP. I am not sure which one to use
but essentially it does not seem to matter much so i picked the one in the
`t1` folder which seems to work fine. Original BSP location is
`tools/pack/chips/sun50iw1p1/configs/t1/sys_config.fex`.

