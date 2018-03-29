# Use additional devices

The kernels shipped with this build the [4.4](https://github.com/ayufan-rock64/linux-kernel) and [mainline](https://github.com/ayufan-rock64/linux-mainline-kernel) do support dynamic enabling of devices via [borrowing of_overlays from Raspberry PI](https://www.raspberrypi.org/documentation/configuration/device-tree.md).

Since the 0.6.27 release all devices exposed on pins are disabled (except SPIDF).

You can easily enable these devices from command line if needed.

You can check the names of all devices here: https://github.com/ayufan-rock64/linux-kernel/blob/release-4.4/arch/arm64/boot/dts/rockchip/rk3328.dtsi, when confronted with pinout you might enable additional UARTs, ethernet interfaces, etc.

## Enable 100Mbit Ethernet interface

The extra ethernet interface is accessible on `Pi-P5+ Bus` which you can access with https://www.pine64.org/?product=rock64-stereo-audio-dac-add-on-board.

To enable it execute this command as `root`:

```bash
enable_dtoverlay eth1 ethernet@ff550000 okay
```

This will enable `eth1` till next reboot. If you want to make it permamently consider adding this line to `/etc/rc.local` or other file that is executed on boot.

## Help wanted

Contribute here to add information about different devices that might be interesting for the users: SPI, I2C, UART, GPIOs.
