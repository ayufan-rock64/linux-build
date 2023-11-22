# Kernel module compilation

Follow these instructions to compile an additional kernel module.

In this example, we'll compile the `ds1307 RTC` kernel module for version `4.4.154-1124`:

1. Obtain your kernel version: `uname -r`
    (ex: `4.4.154-1124-rockchip-ayufan-ged3ce4d15ec1`)
2. Download the kernel source code which matches your kernel version from [github.com/ayufan-rock64/linux-kernel/releases](https://github.com/ayufan-rock64/linux-kernel/releases)
3. Extract the kernel: `tar -zxvf 4.4.154-1124-rockchip-ayufan.tar.gz`
4. Copy the old kernel config:
    ```bash
    cd linux-kernel-4.4.154-1124-rockchip-ayufan
    cp /usr/src/linux-headers-4.4.154-1124-rockchip-ayufan-ged3ce4d15ec1/.config .
    make oldconfig
    ```
5. Install required build packages: `apt-get install bc python libncurses5-dev`
6. Configure the kernel with the additional modules you want: `make menuconfig`
    (ex: `Device Drivers --> [*] Real Time Clock --> <M>   Dallas/Maxim DS1307..`)
7. Exit and save the config
8. Prepare the modules:
    ```bash
    make EXTRAVERSION=-1124-rockchip-ayufan-ged3ce4d15ec1 modules_prepare
    ````
9. Build the module: `make M=drivers/rtc`
    (note: specify the correct directory containing the module you added)
10. Copy the module to the modules directory:
    ```bash
    mkdir -p /lib/modules/4.4.154-1124-rockchip-ayufan-ged3ce4d15ec1/kernel/drivers/rtc/
    cp drivers/rtc/rtc-ds1307.ko /lib/modules/4.4.154-1124-rockchip-ayufan-ged3ce4d15ec1/kernel/drivers/rtc/
    ```
11. Ensure module is added to dep file:
    ```bash
    echo 'kernel/drivers/rtc/rtc-ds1307.ko:' >> /lib/modules/4.4.154-1124-rockchip-ayufan-ged3ce4d15ec1/modules.dep
    ```
12. Load the module:
    ```bash
    depmod -a
    modprobe rtc-ds1307
    ```
13. Ensure module is loaded on boot: `echo "rtc-ds1307" >> /etc/modules`
