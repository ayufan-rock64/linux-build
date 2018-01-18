# Kernel upgrading

The [ayufan](https://github.com/ayufan-rock64/linux-build/releases) builds are released quite frequently.

Upgrading to a newer kernel (ex: `kernel 4.15`) is quite simple:

  1. Uncomment pre-releases from `/etc/apt/sources.list.d/ayufan-rock64.list `
  2. Manually install the `<kernel>`, ex: `linux-image-4.15.0-rockchip-ayufan-177-g59389fa34`

```
apt-get update
apt-get install <kernel>
```

  3. Reboot
