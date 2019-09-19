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

    You have to find the nodes and change their status from `disabled` to `okay`:

    ```text
    pwm@ff420000 {
      compatible = "rockchip,rk3399-pwm", "rockchip,rk3288-pwm";
      ...
      status = "okay"; # changed from `disabled`
      phandle = <0xe1>;
    };
    ```

    The nodes that has to be `status = "okay"` are:

    - `pwm@ff420000 {` (pwm backlight)
    - `lcd-backlight {` (backlight control)
    - `edp-panel {` (edp control)
    - `edp@ff970000 {` (edp interface)

    Exit editor, and confirm that with `YES`:

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

### Pine64 display and touchpad (RockPro64) (BETA)

1. Enable EDP display device-tree nodes:

    ```bash
    sudo dtedit
    ```

    You have to find the nodes and change their status from `disabled` to `okay`:

    ```text
    pwm@ff420000 {
      compatible = "rockchip,rk3399-pwm", "rockchip,rk3288-pwm";
      ...
      status = "okay"; # changed from `disabled`
      phandle = <0xe1>;
    };
    ```

    The nodes that has to be `status = "okay"` are:

    - `pwm@ff420000 {` (pwm backlight)
    - `lcd-backlight {` (backlight control)
    - `dsi@ff960000 {` (dsi interface)
    - `gt9xx@14 {` (touchpad)

    Exit editor, and confirm that with `YES`:

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
