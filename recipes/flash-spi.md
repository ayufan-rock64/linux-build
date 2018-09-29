# Flashing and Erasing the SPI

Traditionally, booting Linux on the [ROCK64](http://wiki.pine64.org/index.php/ROCK64_Main_Page) required an eMMC or microSD card, however it is now possible to boot **without** those, assuming the SPI memory has been flashed. The _ROCK64_ contains an onboard 128Mbit SPI flash memory, which can be flashed with [U-Boot](https://github.com/ayufan-rock64/linux-u-boot) in order to provide additional boot options:

* USB2 / USB3 drive
* PXE
* microSD
* eMMC

## 1. Write the U-Boot image

1. Download the latest [u-boot-flash-spi.img.xz](https://github.com/ayufan-rock64/linux-u-boot/releases/latest) image
2. Write it to a microSD card using `dd` or `Etcher`

    ```bash
    # From Linux or macOS
    xz -k -d -c -v -T 3 u-boot-flash-spi.img.xz | dd of=/dev/<sdcard> bs=1M
    ```

Make sure you write to the correction location, it **will destroy all data**.

## 2. Boot the ROCK64

1. Insert the microSD card
2. Wait for it to boot. It will automatically erase the SPI memory, and flash _U-Boot_
3. You should see: the power LED (white LED) flicker once per second, and:

    ```text
    SF: ... bytes @ 0x8000 Written: OK
    ```

4. Remove the microSD card

### 3. Prepare Linux

Tested successfully with `Debian Stretch Minimal 0.6.15-175`

1. Prepare your device (USB drive, microSD, PXE, whatever) with your chosen [Linux distribution](http://wiki.pine64.org/index.php/ROCK64_Software_Release)
2. Boot method:

    * **Boot from microSD/eMMC/USB drive:** write the image using `dd` or `Etcher`
    * **Boot from PXE:** we assume you already know what you're doing

3. Reset the _ROCK64_
4. You should see _U-Boot_ starting from SPI memory, and then booting Linux

Make sure you remove the microSD card containing the `u-boot-flash-spi` image, otherwise on reset it will erase/write the SPI memory once again.

**Boot order:**

1. SPI flash
2. eMMC (disable with jumper)
3. microSD
4. USB drive
5. PXE

If you're currently running the OS from microSD, and want to switch to a USB/SSD drive, follow the [instructions on this page](https://forum.pine64.org/showthread.php?tid=4971).

### 4. Fix for SPI Flashing failures

If, for any reason, your SPI flashing gets interrupted during its process, you may experience a "frozen" device.

To solve this, on the Rock64 follow these instructions:

1. Go to [this](http://wiki.pine64.org/index.php/NOOB#Step-by-Step_Instructions_to_Flashing_MicroSD_Cards) guide to create a new ayufan bootable Linux SD card
    Or, in short, download the latest ayufan Linux distribution from [here](https://github.com/ayufan-rock64/linux-build/releases/latest), and use [etcher](https://etcher.io/) to flash you SD card

2. Insert the SD card to the Rock64.

3. Connect other peripherals such as network to later control your device, such as via ssh.
    * ayufan’s Linux distro will connect to the network and you will be able to ssh to the device.

4. Ground the SPI Clock (SPI_CLK_M2) on the Pi-2 Bus GPIO pins on the rock64
    * Pin 23 is SPI_CLK_M2
    * Pin 25 is GND
    * Pin layout of the rock64 can be found [here](http://files.pine64.org/doc/rock64/ROCK64_Pi-2%20_and_Pi_P5+_Bus.pdf)
    * Other Rock64 documents can be found [here](https://www.pine64.org/?page_id=7175)

5. Turn on the device and release the grounding of the SPI Clock 2-3 seconds after the device was turned on.
    * **NOTE**: This is a critical step
            If not done correctly you will not be able to flash the device
    * If unsuccessful turn of the device and try again.

6. login and go to the folder with the flashing scripts
    * `cd /usr/local/sbin`
    * `sudo ./rock64_erase_spi_flash.sh` or `sudo ./rock64_write_spi_flash.sh`
    * Type "YES" to flash the device

7. If the flashing failes with an error `loader partition on MTD is not found` repeat step 5.

Your device should now be able to boot without holding the SPI Clock.
