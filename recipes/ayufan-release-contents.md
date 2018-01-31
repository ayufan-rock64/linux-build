# Ayufan release contents

Ayufan releases are built specifically for the `rock64`.

  * The latest [stable release](https://github.com/ayufan-rock64/linux-build/releases/latest) is `0.5.15`
  * The latest [experimental release](https://github.com/ayufan-rock64/linux-build/releases) is `0.6.x` (updated often)

It is **not recommended** to install an **experimental release**, except to obtain certain tools such as the `u-boot-flash` image.

This document aims to answer the questions:

  1. [What](#what-is-included) is included in an `ayufan` release?
  2. [How](#how-are-they-built) are `ayufan` releases built?
  3. [Can](#can-they-be-trusted) `ayufan` releases be trusted?
  4. [But](#but-i-want-my-own) can I modify an `ayufan` release?
  5. [Who](#who-is-ayufan) is `ayufan`?
  6. [Are](#are-there-alternatives) there alternatives to `ayufan` releases?

## What is included

Every build contains the following files available for download:

  * Popular Linux distributions (ex: Debian, Ubuntu, Container Linux)
  * Linux kernel and headers
  * Debian package with custom tools, wallpapers, start scripts, etc
  * U-boot flash and erase images (since `0.6.10`)
  * Source code for all build scripts

Let's focus on the Debian package `linux-rock64-package-0.x.x_all.deb`, whose contents can be [found here](https://github.com/ayufan-rock64/linux-build/tree/master/package/root).

This package is installed on all `ayufan` builds. It's essentially the _"custom"_ stuff added to each base OS.

```
# linux-rock64 package contents

./boot/efi/extlinux/extlinux.conf
./etc/apt/preferences.d/ayufan-ppa
./etc/chromium-browser/customizations/rock64-optimisations
./etc/cron.d/make_nas_processes_faster
./etc/cron.d/startup
./etc/firmware/4343A0.hcd
./etc/firmware/BCM4335C0.hcd
./etc/firmware/BCM4343A0 26M.hcd
./etc/lightdm/lightdm-gtk-greeter.conf.d/99_xxx_rock64.conf
./etc/modprobe.d/.gitkeep
./etc/modules-load.d/.gitkeep
./etc/network/if-up.d/rock64-offload
./etc/network/interfaces.d/eth0
./etc/systemd/system/first-boot.service
./etc/systemd/system/restart-network-manager-after-resume.service
./etc/systemd/system/restore-sound-after-resume.service
./etc/systemd/system/rtk-hciattach.service
./etc/systemd/system/ssh-keygen.service
./etc/systemd/system/store-sound-on-suspend.service
./etc/udev/rules.d/50-hevc-rk3399.rules
./etc/udev/rules.d/50-hevc.rules
./etc/udev/rules.d/50-mail400.rules
./etc/udev/rules.d/50-mail.rules
./etc/udev/rules.d/50-vpu-rk3399.rules
./etc/udev/rules.d/50-vpu.rules
./etc/udev/rules.d/hdmi.rules
./etc/update-motd.d/05-figlet
./etc/X11/xorg.conf.d/20-modesetting.conf
./lib/firmware/rtlbt/rtl8703a_config
./lib/firmware/rtlbt/rtl8703a_fw
./lib/firmware/rtlbt/rtl8703b_config
./lib/firmware/rtlbt/rtl8703b_fw
./lib/firmware/rtlbt/rtl8723a_config
./lib/firmware/rtlbt/rtl8723a_fw
./lib/firmware/rtlbt/rtl8723b_config
./lib/firmware/rtlbt/rtl8723b_config_2Ant_S0
./lib/firmware/rtlbt/rtl8723b_fw
./lib/firmware/rtlbt/rtl8723b_VQ0_config
./lib/firmware/rtlbt/rtl8723b_VQ0_fw
./lib/firmware/rtlbt/rtl8723cs_cg_config
./lib/firmware/rtlbt/rtl8723cs_cg_fw
./lib/firmware/rtlbt/rtl8723cs_vf_config
./lib/firmware/rtlbt/rtl8723cs_vf_fw
./lib/firmware/rtlbt/rtl8723cs_xx_config
./lib/firmware/rtlbt/rtl8723cs_xx_fw
./usr/local/bin/hdmi-toggle
./usr/local/sbin/install_container_linux.sh
./usr/local/sbin/install_desktop.sh
./usr/local/sbin/install_openmediavault.sh
./usr/local/sbin/resize_rootfs.sh
./usr/local/sbin/rock64_diagnostics.sh
./usr/local/sbin/rock64_erase_spi_flash.sh
./usr/local/sbin/rock64_eth0_stats.sh
./usr/local/sbin/rock64_first_boot.sh
./usr/local/sbin/rock64_fix_performance.sh
./usr/local/sbin/rock64_health.sh
./usr/local/sbin/rock64_write_spi_flash.sh
./usr/share/alsa/init/10rockchip
./usr/share/alsa/init/rt5616
./usr/share/alsa/init/rt5640
./usr/share/alsa/init/rt5651
./usr/share/backgrounds/ubuntu-mate-rock64/ROCK64-Wallpaper-1.jpg
./usr/share/backgrounds/ubuntu-mate-rock64/ROCK64-Wallpaper-2.jpg
./usr/share/backgrounds/ubuntu-mate-rock64/ROCK64-Wallpaper-3.jpg
./usr/share/backgrounds/ubuntu-mate-rock64/ROCK64-Wallpaper-4.jpg
./usr/share/backgrounds/ubuntu-mate-rock64/ROCK64-Wallpaper-5.jpg
./usr/share/backgrounds/ubuntu-mate-rock64/ROCK64-Wallpaper-6.jpg
./usr/share/doc/linux-rock64-package/changelog.gz
./usr/share/flash-kernel/db/rock64.db
```

Most files are there to ensure the hardware features of the `rock64` work well. Some scripts can also help with debugging or improving your `rock64` experience:

  * `rock64_health.sh`: outputs the CPU frequency, count, and SoC temperature
  * `rock64_eth0_stats.sh`: outputs statistics about your `eth0` network adapter
  * `install_desktop.sh`: installs a Linux desktop packages if you've installed a `minimal` distribution

It's worth noting, many of these customizations have been borrowed from `pine64`, `armbian`, and other tools designed for SBCs.

## How are they built

A publicly accessible [Jenkins server](https://jenkins.ayufan.eu/job/linux-build-rock-64/) is used to automate creation of various builds. The [full log](https://jenkins.ayufan.eu/job/linux-build-rock-64/lastBuild/console) is available for anyone to see.

The aptly named [linux-build](https://github.com/ayufan-rock64/linux-build) repository contains Makefiles and build scripts for generating each build.

## Can they be trusted

Well, as much as you trust the official Debian or Ubuntu distributions.

A lot of work has been made to ensure visibility into the entire build process, which can't be said for all Linux distributions out there.

You're always free to inspect the sources, build logs, and compare outputs with other similar systems.

## But I want my own

Since all build scripts and sources are available, it is possible to create your own distribution to run on the `rock64`. Many people have done so, including [@aw](https://github.com/aw) who got a custom Devuan Jessie running on the `rock64`.

We won't go into details on _how_ to do it, but it's definitely possible if you're knowledgeable with Linux.

## Who is ayufan

Just some [guy](https://github.com/ayufan). [Buy him a beer](https://www.paypal.me/ayufanpl), he deserves it.

## Are there alternatives

There are many options for the `rock64`, depending on your needs. It is possible to run Android, Armbian, Yocto, and a host of other `arm64` systems on the `rock64`.

A comprehensive list of available operating systems are found here:

  * [http://wiki.pine64.org/index.php/ROCK64_Software_Release](http://wiki.pine64.org/index.php/ROCK64_Software_Release)
  * [https://www.armbian.com/rock64/](https://www.armbian.com/rock64/)
  * [https://github.com/ayufan-rock64/linux-build/releases](https://github.com/ayufan-rock64/linux-build/releases)

## FAQ

Please search the [ROCK64 forum](https://forum.pine64.org/forumdisplay.php?fid=85), and [ROCK64 IRC logs](http://irc.pine64.uk/?) for existing discussion threads.
