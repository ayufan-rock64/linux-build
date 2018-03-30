# Overclocking

It is possible to slightly bump Rock64 specs.

## CPU

Currently CPU is clocked at 1296MHz max. Feel free to check:

```bash
cat /sys/devices/system/cpu/cpufreq/policy0/cpuinfo_cur_freq
```

## GPU

Currently GPU is clocked at 500MHz max. Feel free to check:

```bash
cat /sys/class/devfreq/ff300000.gpu/load
cat /sys/class/devfreq/ff300000.gpu/trans_stat
```

## Video Decoder

Currently video decoder is clocked at 500MHz max. Feel free to check (it crashes as of 0.6.28):

```bash
cat /sys/class/devfreq/ff360000.rkvdec/load
cat /sys/class/devfreq/ff360000.rkvdec/trans_stat
```

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
