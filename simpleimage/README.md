# Simple image creation for Pine64

This script builds a bootable disk image usable to boot a Pine64 to Linux in
aarch64 mode.

## Minimal base image

The simpleimage format is only a minimal disk with partition table, bootloader
ramdisk and Kernel.

```
Header      : 20 MiB Bootloader
Partition 1 : 50 MiB vFAT label:BOOT
Partition 2 :        ext4 label:rootfs
```

By default the simple image does not contain any rootfs and spawns a shell on
the UART tty.

## Rootfs

The simpleimage disk image can be extended with a root file system containing
a aarch64 Linux distribtion. The initrd will automatically try to boot this
rootfs if it finds an executable /sbin/init inside the second partition.

Use `make-rootfs.sh` script to create a root file system on a target partition.

## Platform scripts

To help with various tasks some scripts are available in the `platform-scripts`
folder.

### Update helpers for U-Boot and Kernel

To update the U-Boot and Kernel, run the following commands (as root) on your
Pine64.

```bash
curl -s https://raw.githubusercontent.com/longsleep/build-pine64-image/master/simpleimage/platform-scripts/pine64_update_uboot.sh | sudo bash
curl -s https://raw.githubusercontent.com/longsleep/build-pine64-image/master/simpleimage/platform-scripts/pine64_update_kernel.sh | sudo bash
```

This downloads the latest versions of the update scripts which check if there
is an update, the downloads the update file, validates it with GPG and applies
it to the current system when validation is successful.
