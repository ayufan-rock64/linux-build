## Get Kernel tree

```bash
git clone --depth 1 --branch a64-v1 --single-branch https://github.com/apritzel/linux.git linux-a64-v1
```

## Configure Kernel

Start by copying the `pine64_config_linux` file to `.config` of your Linux
Kernel folder.

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig
```

## Compile Kernel

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- clean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 Image
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 dtbs
```

## Ramdisk

Either make one with the steps below or download one from some other place.
Make sure the initrd is for aarch64.

### Get Busybox tree

```bash
git clone --depth 1 --branch 1_24_stable --single-branch git://git.busybox.net/busybox busybox
```

### Configure and build Busybox

Build a static busybox for aarch64. Start by copying the `pine64_config_busybox`
file to `.config` of your Busybox folder.

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 oldconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4
```

### Make initrd.gz

Use the provided `make_initrd.sh` script to create a simple initrd based on
the busybox binary compiled earlier.

## Next steps

Now that you have a Kernel and initrd, combine them with the provided
`make_and_copy_android_kernel_image.sh` script. This produces a kerne.img and
copies it together with the compiled device tree to a target location. Both
files are needed for booting. So put them on a partition which is readable by
U-Boot. If you do not have that location yet, just use the current directory
and create the files there.

To build a disk image now, go to the `simpleimage` folder. It automatically
picks up the kernel.img and dtb from here.
