# Dual booting

**This is only supported on images up to 0.5.x.**

_U-Boot_ provides the ability to select which OS image/kernel to use when booting.

The following instructions were borrowed from user **maal** on the [PINE64 forum](https://forum.pine64.org/showthread.php?tid=5363&pid=34795#pid34795).

**Note: This is experimental and may break upgradability.**

## 1. Mount the boot partition

If it's not already mounted, make sure `/boot/efi` is mounted. The `<device>` should be `sda6` if booted from USB, `mmcblk0p6` or `mmcblk1p6` if booted from microSD.

```bash
mount -t vfat /dev/<device> /boot/efi
```

## 2. Edit extlinux.conf

Add the following entries to `/boot/efi/extlinux/extlinux.conf`:

```
timeout 1200
default kernel-4.15
menu title ROCK64 Boot Menu
```

Also, make sure you copy and modify the `label/kernel/initrd/fdt/append` lines for additional boot options.

The final `/boot/efi/extlinux/extlinux.conf` file should look like similar to this:

```
timeout 1200
default kernel-4.15
menu title ROCK64 Boot Menu

label kernel-4.4
    kernel /Image
    initrd /initrd.img
    fdt /dtb
    append earlycon=uart8250,mmio32,0xff130000 rw root=LABEL=linux-root rootwait rootfstype=ext4 init=/sbin/init coherent_pool=1M ethaddr=${ethaddr} eth1addr=${eth1addr} serial=${serial#} rock64_label=kernel-4.4

label kernel-4.15
    kernel /Image-4.15
    initrd /initrd-4.15.img
    fdt /dtb-4.15
    append earlycon=uart8250,mmio32,0xff130000 rw root=LABEL=linux-root rootwait rootfstype=ext4 init=/sbin/init coherent_pool=1M ethaddr=${ethaddr} eth1addr=${eth1addr} serial=${serial#} rock64_label=kernel-4.15
```

This will default boot from the `kernel-4.15` label after a 2 minute (1200 * 1/10s = 120 seconds) timeout. *(thanks to [easyfab](https://forum.pine64.org/showthread.php?tid=5363&pid=34983#pid34983) for the correction).

This might seem obvious, but make sure to copy your new kernel and OS files (ex: `Image-4.15, initrd-4.15.img, dtb-4.15`) to `/boot/efi/`.

## 3. Reboot

Unmount the boot partition, then reboot:

```bash
umount /dev/<device>
reboot
```

On reboot, you should be presented with a menu similar to this:

```
ROCK64 Boot Menu
1:      kernel-4.4
2:      kernel-4.15
Enter choice:
```

Enter your choice, and it should boot the desired image/kernel.

```
Enter choice: 2
2:      kernel-4.15
Retrieving file: /Image-4.15
...
```
