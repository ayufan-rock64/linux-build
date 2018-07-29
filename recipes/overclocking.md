# Overclocking

**This guide can be used only on Rock64 and 4.4 kernel currently.**

It is possible to slightly bump Rock64 specs.

**Keep in mind that this can break your board.**

## CPU

Currently CPU is clocked at 1296MHz max. Feel free to check:

### Check frequency and health

You can quickly run rock64 diagnostics to see most vital parameters of your board (CPU frequency, temperature of SoC, and CPU usage):

```bash
rock64_diagnostics.sh -m
```

You can always quickly check current actual CPU frequency:

```bash
cat /sys/devices/system/cpu/cpufreq/policy0/cpuinfo_cur_freq
```

### Add additional operating point (dynamically)

Use dt overlays to add additional 1.392GHz operating point (requires at least 0.6.13):

```bash
enable_dtoverlay 1398mhz cpu0-opp-table okay "opp-1392000000 {
            opp-hz = /bits/ 64 <1392000000>;
            opp-microvolt = <1350000>;
            opp-microvolt-L0 = <1350000>;
            opp-microvolt-L1 = <1325000>;
            clock-latency-ns = <40000>;
}"
```

You can also add 1.512GHz operating point (ensure that you have good heatsink):

```bash
enable_dtoverlay 1512mhz cpu0-opp-table okay "opp-1512000000 {
            opp-hz = /bits/ 64 <1512000000>;
            opp-microvolt = <1450000 1450000 1450000>;
            opp-microvolt-L0 = <1450000 1450000 1450000>;
            opp-microvolt-L1 = <1425000 1425000 1450000>;
            clock-latency-ns = <40000>;
}"
```

Then, force to reload frequency table:

```bash
echo cpufreq-dt > /sys/bus/platform/drivers/cpufreq-dt/unbind
echo cpufreq-dt > /sys/bus/platform/drivers/cpufreq-dt/bind
```

At very least verify that a new operating point is loaded:

```bash
cat /sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies 
408000 600000 816000 1008000 1200000 1296000 1392000
```

### Stability testing

With every overclocking it is important to perform stability testing. The best for that is [cpuburn](https://github.com/ssvb/cpuburn-arm):

```bash
cd /usr/src
git clone https://github.com/ssvb/cpuburn-arm
cd cpuburn-arm
gcc -o cpuburn-a53 cpuburn-a53.S
./cpuburn-a53
```

On other terminal session run:

```bash
rock64_diagnostics.sh -m
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
