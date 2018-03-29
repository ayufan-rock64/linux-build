# Overclocking

It is possible to slightly bump Rock64 specs.

## CPU

TBD

## eMMC

TBD

## RAM

The Rock64 boots with DDR333 configured. This is the most safe configuration,
but then immediately switches to DDR786MHz mode.

It is possible to overclock the DRAM slightly by using:

```bash
echo 933000000 > /sys/bus/platform/drivers/rockchip-dmc/dmc/devfreq/dmc/max_freq
echo performance > /sys/bus/platform/drivers/rockchip-dmc/dmc/devfreq/dmc/governor
```

You can see actually assigned speed with:

```bash
cat /sys/bus/platform/drivers/rockchip-dmc/dmc/devfreq/dmc/load
cat /sys/bus/platform/drivers/rockchip-dmc/dmc/devfreq/dmc/trans_stat
```

**This works only on 4.4 kernel, and has negative effects on mainline kernel,
as mainline does not support dynamic memory controller.**
