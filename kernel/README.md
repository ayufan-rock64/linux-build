# Linux Kernel for Pine64

This scripting helps in configuring and compiling the Kernel for Pine64. To
compile, you need a properly set up gcc-aarch64-linux-gnu toolchain. The
recommended version to compile the Kernel is 5.3.

## Mainline Kernel

There is a mainlining process in the works. The first set of patches has been
created.  If you are a developer work on this tree and get in touch with the
linux-sunxi community on IRC (http://linux-sunxi.org/IRC). Else scroll down to
 Kernel 3.10 from BSP section.

```bash
git clone --depth 1 --branch a64-v4 --single-branch https://github.com/apritzel/linux.git linux-a64
```

### Configure mainline Kernel

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig
```

### Compile mainline Kernel

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- clean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 Image
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 modules
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 dtbs
```

This creates the Kernel image in `arch/arm64/boot/Image` and the binary
device trees in `arch/arm64/boot/dts/allwinner`.

## Kernel 3.10 from BSP

While mainlining is in the works you might want to try the Kernel which is
released in the BSP. Unsurprisingly this Kernel tree has its problems and needs
fixing. Thus clone my fixed tree like below.

```bash
git clone --depth 1 --branch pine64-hacks-1.2 --single-branch https://github.com/longsleep/linux-pine64.git linux-pine64
```

This tree is based on mainline 3.10.65 with the changes from the Lichee
applied. On top it has some backports and fixed to make it actually compile and
work without issues on modern Linux distributions.

### Configure BSP Kernel

In my tree, i ship a ready to use Kernel configuration in `arch/arm64/configs/sun50iw1p1smp_linux_defconfig`.

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- sun50iw1p1smp_linux_defconfig
```

### Compile BSP Kernel

```
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LOCALVERSION= clean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 LOCALVERSION= Image
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 LOCALVERSION= modules
```

This creates the Kernel image in `arch/arm64/boot/Image`.

We do not compile a device tree with the BSP Kernel tree as it does not
contain any proper source for the Pine64. Instead this build repository
contains a device tree source in `blobs/pine64.dts` which was extracted and
dumped from BSP tarball.

With the BSP Kernel, MMC, USB and Ethernet (at 100baseTx-FD) work. And Arch
Linux boots just fine when used as rootfs together with the rest of the tools
found in this build scripts repository.

### Compile BSP Mali Kernel module

The BSP Kernel tree also contains the graphics driver in `modules/gpu`.

```
cd modules/gpu
LICHEE_KDIR=$(pwd)/../.. ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LICHEE_PLATFORM=Pine64 make build
```

This will compile the mali.ko Kernel module with the Kernel .config found in
LICHEE_KDIR. To use that module with Linux, copy it to `/lib/modules/${version}/kernel/extramodules` or some other directory which can contain Kernel modules.

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

Now that you have a Kernel and initrd copy them together with the compiled
device tree to a target location. You can use the `install_kernel.sh` script
to do that for you. So put them on a partiion which is readable by U-Boot. If
you do not have that location yet, just use "-" to put the files into
`../build` folder to be picked up later.

The tooling in simpleimage supports both mainline and BSP Kernel builds.

To build a disk image now, go to the `simpleimage` folder. It automatically
picks up the just generated files from `../build`.
