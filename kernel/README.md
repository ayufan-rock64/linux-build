## Compile Kernel

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- clean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 Image
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 dtbs
```

