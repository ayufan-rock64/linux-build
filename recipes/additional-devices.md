# Use additional devices

The kernels shipped with this build the [4.4](https://github.com/ayufan-rock64/linux-kernel) and [mainline](https://github.com/ayufan-rock64/linux-mainline-kernel) do support dynamic enabling of devices via [borrowing of_overlays from Raspberry PI](https://www.raspberrypi.org/documentation/configuration/device-tree.md).

**This requires to use at least the `0.9.x >=` releases.**

## Enable 100Mbit Ethernet interface (Rock64)

The extra ethernet interface is accessible on `Pi-P5+ Bus` which you can access with https://www.pine64.org/?product=rock64-stereo-audio-dac-add-on-board.

```bash
sudo systemctl start kernel-overlay@fast-ethernet
sudo systemctl enable kernel-overlay@fast-ethernet
```

## Manually editting device-tree

It is possible to manually edit currently running `device-tree`
with `dtedit` command.

### EDP display (RockPro64) (BETA)

1. Enable EDP display device-tree nodes:

    ```bash
    sudo dtedit
    ```

    Add the following text at the end of file:

    ```text
    / {
      pwm@ff420000 {
        status = "okay";
      };

      lcd-backlight {
        status = "okay";
      };

      edp-panel {
        status = "okay";
      };

      edp@ff970000 {
        status = "okay";
      };
    };
    ```

    Exit editor, and confirm that with `YES` and reboot:

    ```bash
    Use overlay or not?
    Say YES or NO or DROP:
    YES
    ```

    **You have to re-run `dtedit` if you update the kernel.**

2. To disable overlays you have to do:

    ```bash
    sudo dtedit
    # close editor
    # and select DROP
    ```

### Pine64 display and touchscreen (RockPro64) (BETA)

1. Enable display and touchscreen device-tree nodes:

    ```bash
    sudo dtedit
    ```

    Add the following text at the end of file:

    ```text
    / {
      pwm@ff420000 {
        status = "okay";
      };

      lcd-backlight {
        status = "okay";
      };

      dsi@ff960000 {
        status = "okay";
      };

      i2c@ff3d0000 {
        gt9xx@14 {
          status = "okay";
        };
      };
    };
    ```

    Exit editor, and confirm that with `YES` and reboot:

    ```bash
    Use overlay or not?
    Say YES or NO or DROP:
    YES
    ```

    **You have to re-run `dtedit` if you update the kernel.**

2. To disable overlays you have to do:

    ```bash
    sudo dtedit
    # close editor
    # and select DROP
    ```

## Help wanted

Contribute here to add information about different devices that might be interesting for the users: SPI, I2C, UART, GPIOs.
