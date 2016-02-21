# Simple image creation for Pine64

This script builds a bootable disk image usable to boot a Pine64 to Linux in
aarch64 mode.

## Simpleimage

Tee simpleimage format is only a minimal disk with partition table, bootloader
ramdisk and Kernel.

  Header      : 20 MiB Bootloader
  Partition 1 : 50 MiB vFAT label:ROOT
  Partition 2 :        ext4 label:rootfs

By default the simple image does not contain any rootfs and spawns a shell on
the UART tty.

## Rootfs

The simpleimage disk image can be extended with a root file system containing
a aarch64 Linux distribtion. The initrd will automatically try to boot this
rootfs if it finds an executable /sbin/init inside the second partition.

Use `make-rootfs.sh` script to create a root file system on a target partition.

### Arch Linux

#### Install X11 with Xfce on Arch Linux

First become root with `su -`. Default root password is `root`.

```bash
# pacman -S xorg-server xorg-xinit xorg-utils xorg-server-utils
# pacman -S xf86-video-fbdev xf86-video-fbturbo-git
# pacman -S xfce4 xfce4-goodies
# pacman -S lightdm lightdm-gtk-greeter
# systemctl enable lightdm
```

This will launch a graphical log in screen. Use `alarm` with password `alarm`
to start a Xfce4 desktop environment.
