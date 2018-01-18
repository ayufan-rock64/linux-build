# Flashing and Erasing the SPI

Traditionally, booting Linux on the [ROCK64](http://wiki.pine64.org/index.php/ROCK64_Main_Page) required an eMMC or microSD card, however it is now possible to boot **without** those, assuming the SPI memory has been flashed. The _ROCK64_ contains an onboard 128Mbit SPI flash memory, which can be flashed with [U-Boot](https://github.com/ayufan-rock64/linux-u-boot) in order to provide additional boot options:

  * USB2 / USB3 drive
  * PXE
  * microSD
  * eMMC

### 1. Write the U-Boot image

  1. Download the latest [u-boot-flash-spi.img.xz](https://github.com/ayufan-rock64/linux-build/releases) image
  2. Write it to a microSD card

    # From Linux or macOS
    xz -k -d -c -v -T 3 u-boot-flash-spi.img.xz | dd of=/dev/<sdcard> bs=1M

Make sure you write to the correction location, it **will destroy all data**.

### 2. Boot the ROCK64

  1. Insert the microSD card
  2. Wait for it to boot. It will automatically erase the SPI memory, and flash _U-Boot_
  3. You should see: the power LED (white LED) flicker once per second, and:

    SF: ... bytes @ 0x8000 Written: OK

  4. Remove the microSD card

### 3. Prepare Linux

Tested successfully with `Debian Stretch Minimal 0.6.15-175`

  1. Prepare your device (USB drive, microSD, PXE, whatever) with your chosen [Linux distribution](http://wiki.pine64.org/index.php/ROCK64_Software_Release)
  2. Boot method:
    * **Boot from microSD/eMMC/USB drive:** write the image using `dd` or `Etcher`
    * **Boot from PXE:** we assume you already know what you're doing
  4. Reset the _ROCK64_
  5. You should see _U-Boot_ starting from SPI memory, and then booting Linux

Make sure you remove the microSD card containing the `u-boot-flash-spi` image, otherwise on reset it will erase/write the SPI memory once again.

**Boot order:**

  1. SPI flash
  2. eMMC (disable with jumper)
  3. microSD
  4. USB drive
  5. PXE

If you're currently running the OS from microSD, and want to switch to a USB/SSD drive, follow the [instructions on this page](https://forum.pine64.org/showthread.php?tid=4971).

## FAQ

  Please search the [ROCK64 forum](https://forum.pine64.org/forumdisplay.php?fid=85), and [ROCK64 IRC logs](http://irc.pine64.uk/?) for existing discussion threads.
