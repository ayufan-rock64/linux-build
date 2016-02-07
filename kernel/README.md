## Get Kernel tree

```bash
git clone --depth 1 --branch a64-v1 --single-branch https://github.com/apritzel/linux.git linux-a64-v1

## Configure Kernel

TODO: .config

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig
```

## Compile Kernel

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- clean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 Image
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 dtbs
```

## Busybox based initrd

Build a static busybox for aarch64. TODO: .config

```bash
git clone --depth 1 --branch 1_24_stable --single-branch git://git.busybox.net/busybox busybox
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 oldconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4
