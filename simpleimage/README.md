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

### Ubuntu Linux

#### Install full Xubuntu desktop

Xubuntu is an elegant and easy to use operating system. Xubuntu comes with
Xfce, which is a stable, light and configurable desktop environment. For more
details see http://xubuntu.org/.

```
bash
# sudo apt-get update
# sudo apt-get install xubuntu-desktop
```

This downloads and installs loads of packages which at the end gives you a
full installed Xubuntu desktop. At the current MMC speeds of the Pine64 it
will take several hours to complete. Xubuntu needs around 2.5GiB additional
space, so you might want to enlarge the rootfs partition before installing.


## Platform scripts

To help with various tasks some scripts are available in the `platform-scripts`
folder.

### Update helpers for U-Boot and Kernel

To update the U-Boot and Kernel, run the following commands (as root) on your
Pine64.

```bash
bash <(curl -s https://raw.githubusercontent.com/longsleep/build-pine64-image/master/simpleimage/platform-scripts/pine64_update_uboot.sh)
bash <(curl -s https://raw.githubusercontent.com/longsleep/build-pine64-image/master/simpleimage/platform-scripts/pine64_update_kernel.sh)
```

This downloads the latest versions of the updaet scripts which check if there
is an update, the downloads the update file, validates it with gpg and applies
it to the current system when validation is successfull.
