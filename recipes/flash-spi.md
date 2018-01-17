# Flashing and Erasing the SPI

Traditionally, booting Linux on the [ROCK64](http://wiki.pine64.org/index.php/ROCK64_Main_Page) required an eMMC or microSD card, however it is now possible to boot **without** those, assuming the SPI memory has been flashed.

The _ROCK64_ contains an onboard 128Mbit SPI flash memory, which can be flashed with [U-Boot](https://github.com/ayufan-rock64/linux-u-boot) in order to provide additional boot options:

  * USB2 / USB3 drive
  * PXE

This how-to is split in two sections:

  1. [New installation](#new-installation): If you're starting from scratch
  2. [Existing installation](#existing-installation): If you're already running Linux on your _ROCK64_

## New installation

If you're starting from scratch, you will need to perform the following tasks:

  1. Write the _U-Boot_ image to a microSD card
  2. Boot the _ROCK64_ from the microSD card to begin flashing
  3. Prepare Linux on your USB/PXE/microSD/eMMC device

### 1. Write the U-Boot image

Download the latest [u-boot-flash-spi.img.xz](https://github.com/ayufan-rock64/linux-build/releases) image, and write it to a microSD card.

```bash
# From Linux or macOS
xz -k -d -c -v -T 3 u-boot-flash-spi.img.xz | dd of=/dev/<sdcard> bs=1M
```

This will decompress, extract, and write _U-Boot_ to `/dev/<sdcard>`. Make sure you write to the correction location, as this process **will destroy all data**.

### 2. Boot the ROCK64

Insert the microSD card and wait for it to boot. The card will automatically begin erasing the SPI memory, and flashing _U-Boot_.

Once complete, you should see: `SF: ... bytes @ 0x8000 Written: OK`. On success, you should also see the power LED (white LED) flickering once per second.

At this point, you can remove the microSD card.

### 3. Prepare Linux

If you haven't already done so, prepare your device (USB drive, microSD, PXE, whatever) with your chosen [Linux distribution](http://wiki.pine64.org/index.php/ROCK64_Software_Release).

> To boot from a USB drive, you will need to write one of those images using `dd` or `Etcher`. Once complete, connect the USB drive to your _ROCK64_ (obviously).

This procedure has been tested successfully with `Debian Stretch Minimal 0.6.15-175`.

> To boot from PXE, we assume you already know what you're doing.

Make sure you remove the microSD card containing the `u-boot-flash-spi` image, otherwise on reset it will erase/write the SPI memory once again.

Reset the _ROCK64_, and it will search for your USB device, and boot directly from it (thanks to U-Boot in the SPI memory).

**Boot order:**

  1. microSD
  2. USB drive
  3. PXE

## Existing installation

If you already have an `ayufan` Linux release running on your _ROCK64_:

  - For version `0.5.x`: Download the [rock64_write_spi_flash.sh](https://github.com/ayufan-rock64/linux-build/blob/master/package/root/usr/local/sbin/rock64_write_spi_flash.sh) script, and run it
  - For version `0.6.x`: Run `apt-get update; apt-get upgrade`, then run `rock64_write_spi_flash.sh`

Once complete, reboot. It should "just work".

If you're not running an `ayufan` Linux build `v0.5+`, then follow the procedure for [New installation](#new-installation).

If you're currently running the OS from microSD, and want to switch to a USB/SSD drive, follow the [instructions on this page](https://forum.pine64.org/showthread.php?tid=4971).

## FAQ

  Please search the [ROCK64 forum](https://forum.pine64.org/forumdisplay.php?fid=85), and [ROCK64 IRC logs](http://irc.pine64.uk/?) for existing discussion threads.
