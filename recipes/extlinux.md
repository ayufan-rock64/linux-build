# Extlinux

Since the version 0.6.58 there's a new `extlinux` helper code that replaces `flash-kernel`
making it possible to have completely device agnostic images,
as long as images do have SPI flash and u-boot loaded there (not yet, but in the future).

The new extlinux makes it easy to switch between all installed kernel versions.

The `extlinux.conf` is generated from contents of `/boot` and `/etc/default/extlinux`.
**The configuration is automatically generated on the kernel installation.**

You can edit `/etc/default/extlinux` to configure for example command line.

## Enable it

```bash
new_extlinux_boot.sh rootfs
```

It will make to boot device from `/` instead of `/boot/efi` that was used before.

## Disable it

```bash
new_extlinux_boot.sh flash-kernel
```

## Manually regenerate configuration

```bash
update_extlinux.sh
```

## Inspect configuration

The result is stored in `/boot/extlinux/extlinux.conf`.
