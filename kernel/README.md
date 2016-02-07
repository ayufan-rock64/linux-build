## Get Kernel tree

```bash
git clone --depth 1 --branch a64-v1 --single-branch https://github.com/apritzel/linux.git linux-a64-v1

## Compile Kernel

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- clean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 Image
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 dtbs
```

